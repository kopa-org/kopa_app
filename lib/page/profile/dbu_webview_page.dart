import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:kopa/repository/scraper_repository.dart';
import 'package:kopa/utils/app_analytics.dart';

class DbuWebviewPage extends StatefulWidget {
  const DbuWebviewPage({super.key});

  @override
  State<DbuWebviewPage> createState() => _DbuWebviewPageState();
}

class _DbuWebviewPageState extends State<DbuWebviewPage> {
  late final WebViewController controller;
  String? _scraperScript;
  bool _isLoadingScraper = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'DbuChannel',
        onMessageReceived: (JavaScriptMessage message) {
          if (mounted) {
            final String rawJson = message.message;
            try {
              AppAnalytics.logEvent('dbu_calendar_import_success');
              context.pop(rawJson);
            } catch (e) {
              context.pop(rawJson);
            }
          }
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
              await controller.runJavaScript(script);
            } catch (e) {
              debugPrint('Error extracting ical link: $e');
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
      });
      await controller.loadRequest(
        Uri.parse('https://mit.dbu.dk/MyTeam/MyTeams.aspx#'),
      );
    } catch (e) {
      AppAnalytics.logEvent('dbu_calendar_import_failure');
      if (!mounted) return;
      setState(() {
        _isLoadingScraper = false;
        _loadError = 'Kunne ikke hente DBU-importlogik fra serveren.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DBU Login'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          if (_loadError == null) WebViewWidget(controller: controller),
          if (_isLoadingScraper)
            const Center(
              child: CircularProgressIndicator(),
            ),
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
