import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:kopa/repository/scraper_repository.dart';
import 'package:kopa/utils/app_analytics.dart';

enum DbuWebviewOperation {
  fullImport('full_import'),
  standings('standings');

  final String wireValue;

  const DbuWebviewOperation(this.wireValue);
}

class DbuWebviewPage extends StatefulWidget {
  final DbuWebviewOperation operation;

  const DbuWebviewPage({
    super.key,
    this.operation = DbuWebviewOperation.fullImport,
  });

  @override
  State<DbuWebviewPage> createState() => _DbuWebviewPageState();
}

class _DbuWebviewPageState extends State<DbuWebviewPage> {
  late final WebViewController controller;
  String? _scraperScript;
  bool _isLoadingScraper = true;
  bool _isScraping = false;
  String? _loadError;
  Map<String, dynamic>? _poolSyncContext;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'DbuChannel',
        onMessageReceived: (JavaScriptMessage message) async {
          if (!mounted) return;

          final String rawJson = message.message;
          Map<String, dynamic>? decoded;
          try {
            decoded = jsonDecode(rawJson) as Map<String, dynamic>;
          } catch (_) {
            if (widget.operation == DbuWebviewOperation.fullImport) {
              context.pop(rawJson);
            }
            return;
          }

          if (decoded['operation'] == 'pool_context') {
            _poolSyncContext = (decoded['context'] as Map<dynamic, dynamic>)
                .cast<String, dynamic>();
            final poolId = _poolSyncContext?['dbuPoolId'];
            await controller.loadRequest(
              Uri.parse(
                'https://www.dbu.dk/resultater/pulje/$poolId/stilling',
              ),
            );
            return;
          }

          AppAnalytics.logEvent(
            widget.operation == DbuWebviewOperation.fullImport
                ? 'dbu_calendar_import_success'
                : 'dbu_pool_scrape_success',
            parameters: widget.operation == DbuWebviewOperation.fullImport
                ? null
                : {'operation': widget.operation.wireValue},
          );
          if (mounted) context.pop(rawJson);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            final script = _scraperScript;
            if (script == null) {
              return;
            }

            try {
              final loginFormVisible =
                  await controller.runJavaScriptReturningResult(
                '''
                    !!document.querySelector(
                      '#loginForm, input[type="password"], '
                      + 'input[name*="Password"], input[id*="Password"]'
                    )
                    ''',
              );
              final requiresLogin = loginFormVisible == true ||
                  loginFormVisible.toString() == 'true';

              if (mounted) {
                setState(() => _isScraping = !requiresLogin);
              }

              final contextJson =
                  jsonEncode(_poolSyncContext).replaceAll('</', r'<\/');
              await controller.runJavaScript(
                "window.KopaDbuOperation = '${widget.operation.wireValue}';"
                'window.KopaDbuContext = $contextJson;\n'
                '$script',
              );
            } catch (e) {
              debugPrint('Error extracting DBU context: $e');
              if (mounted) {
                setState(() => _isScraping = false);
              }
            }
          },
        ),
      );

    _loadScraperAndOpenDbu();
  }

  Future<void> _loadScraperAndOpenDbu() async {
    try {
      final manifest = await ScraperRepository.getDbuScraper();
      if (!mounted) return;
      setState(() {
        _scraperScript = manifest.script;
        _isLoadingScraper = false;
        _isScraping = false;
      });
      await controller.loadRequest(
        Uri.parse('https://mit.dbu.dk/MyTeam/MyTeams.aspx#'),
      );
    } catch (e) {
      AppAnalytics.logEvent('dbu_calendar_import_failure');
      if (!mounted) return;
      setState(() {
        _isLoadingScraper = false;
        _isScraping = false;
        _loadError = 'Kunne ikke hente DBU-importlogik fra serveren.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(switch (widget.operation) {
          DbuWebviewOperation.fullImport => 'DBU Login',
          DbuWebviewOperation.standings => 'Synkroniser stilling',
        }),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          if (_loadError == null) WebViewWidget(controller: controller),
          if (_isLoadingScraper || _isScraping) const _BlockingLoader(),
          if (_loadError != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _loadError!,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BlockingLoader extends StatelessWidget {
  const _BlockingLoader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        const ModalBarrier(
          dismissible: false,
          color: Color(0x66000000),
        ),
        Center(
          child: Material(
            color: colorScheme.surface,
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 28, vertical: 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
