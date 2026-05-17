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
      ..addJavaScriptChannel(
        'DbuChannel',
        onMessageReceived: (JavaScriptMessage message) {
          if (mounted) {
            final String rawJson = message.message;
            try {
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
            try {
              await controller.runJavaScript('''
                (function() {
                  // Auto-toggle "Husk mig til næste gang" checkbox
                  var cb = document.getElementById('cbRemberMe');
                  if (cb && !cb.checked) {
                    cb.click();
                  }

                  var url = window.location.href.toLowerCase();
                  
                  if (url.includes('myteams.aspx')) {
                    var btn = document.getElementById('cphMain_SSBtnICal');
                    if (btn) {
                      var onclick = btn.getAttribute('onclick');
                      if (onclick) {
                        var match = onclick.match(/webcal:\\/\\/[^']+/);
                        if (match) {
                          sessionStorage.setItem('kopa_webcal', match[0]);
                          var teamLinks = Array.from(document.querySelectorAll('a')).filter(a => a.href && a.href.includes('__doPostBack') && a.id && (a.id.includes('lbTeamName') || a.id.includes('rgPlayer') || a.id.includes('rgCoach')));
                          if (teamLinks.length > 0) {
                            eval(teamLinks[0].getAttribute('href').replace('javascript:', ''));
                          } else {
                            DbuChannel.postMessage(JSON.stringify({ webcal: match[0], matches: [] }));
                          }
                        }
                      }
                    }
                  } else if (url.includes('myteam.aspx') || url.includes('matchlist.aspx') || url.includes('activities.aspx')) {
                    var webcal = sessionStorage.getItem('kopa_webcal');
                    if (webcal) {
                      Promise.all([
                        fetch('https://mit.dbu.dk/MyTeam/MatchList.aspx').then(function(r) { return r.text(); }),
                        fetch('https://mit.dbu.dk/MyTeam/PlayerList.aspx').then(function(r) { return r.text(); })
                      ]).then(function(results) {
                          var matchHtml = results[0];
                          var playerHtml = results[1];
                          try {
                            var parser = new DOMParser();
                            var doc = parser.parseFromString(matchHtml, 'text/html');
                            var table = doc.querySelector('table.rgMasterTable');
                            var matches = [];
                            if (table) {
                              var rows = table.querySelectorAll('tr');
                              for (var i = 1; i < rows.length; i++) {
                                var tds = rows[i].querySelectorAll('td');
                                if (tds.length >= 5) {
                                  var date = tds[1].innerText.trim();
                                  var time = tds[2].innerText.trim();
                                  var matchInfo = tds[3].innerText.trim();
                                  var result = tds[4].innerText.trim();
                                  if (matchInfo.length > 0 && date.includes('-')) {
                                    var title = matchInfo.split(' Kampnr:')[0].trim();
                                    var dateParts = date.split('-');
                                    var fullDateStr = "";
                                    if (dateParts.length === 3) {
                                       fullDateStr = "20" + dateParts[2] + dateParts[1] + dateParts[0] + "T" + time.replace(":", "") + "00Z";
                                    }
                                    matches.push({ summary: title, result: result, dtstart: fullDateStr });
                                  }
                                }
                              }
                            }

                            var playerDoc = parser.parseFromString(playerHtml, 'text/html');
                            var playerTables = playerDoc.querySelectorAll('table');
                            var players = [];
                            for (var t = 0; t < playerTables.length; t++) {
                              var pRows = playerTables[t].querySelectorAll('tr');
                              if (pRows.length > 0) {
                                var headers = Array.from(pRows[0].querySelectorAll('th,td')).map(function(x) { return x.innerText.trim(); });
                                var nameIdx = headers.indexOf('Navn');
                                var contactIdx = headers.indexOf('Kontaktinfo');
                                
                                if (nameIdx !== -1 && contactIdx !== -1) {
                                  for (var r = 1; r < pRows.length; r++) {
                                    var pTds = pRows[r].querySelectorAll('td');
                                    if (pTds.length > Math.max(nameIdx, contactIdx)) {
                                      var name = pTds[nameIdx].innerText.trim().split('\\n')[0];
                                      var contact = pTds[contactIdx].innerText.trim().split('\\n')[0];
                                      if (name) {
                                        players.push({ name: name, contact: contact });
                                      }
                                    }
                                  }
                                  break;
                                }
                              }
                            }

                            sessionStorage.removeItem('kopa_webcal');
                            DbuChannel.postMessage(JSON.stringify({ webcal: webcal, matches: matches, players: players }));
                          } catch(e) {
                            sessionStorage.removeItem('kopa_webcal');
                            DbuChannel.postMessage(JSON.stringify({ webcal: webcal, matches: [], players: [] }));
                          }
                        })
                        .catch(function(e) {
                          sessionStorage.removeItem('kopa_webcal');
                          DbuChannel.postMessage(JSON.stringify({ webcal: webcal, matches: [], players: [] }));
                        });
                    }
                  }
                })();
              ''');
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
