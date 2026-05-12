import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:go_router/go_router.dart';

class DbuWebviewPage extends StatefulWidget {
  const DbuWebviewPage({super.key});

  @override
  State<DbuWebviewPage> createState() => _DbuWebviewPageState();
}

class _DbuWebviewPageState extends State<DbuWebviewPage> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            try {
              final result = await controller.runJavaScriptReturningResult('''
                (function() {
                  var btn = document.getElementById('cphMain_SSBtnICal');
                  if (btn) {
                    var onclick = btn.getAttribute('onclick');
                    if (onclick) {
                      var match = onclick.match(/webcal:\\/\\/[^']+/);
                      if (match) return match[0];
                    }
                  }
                  return null;
                })();
              ''');
              
              if (result != null && result.toString() != 'null') {
                final link = result.toString().replaceAll('"', '').replaceAll("'", "").replaceAll('&amp;', '&');
                if (mounted && link.startsWith('webcal')) {
                  context.pop(link);
                }
              }
            } catch (e) {
              debugPrint('Error extracting ical link: \$e');
            }
          },
        ),
      )
      ..loadRequest(Uri.parse('https://mit.dbu.dk/MyTeam/MyTeams.aspx#'));
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
      body: WebViewWidget(controller: controller),
    );
  }
}
