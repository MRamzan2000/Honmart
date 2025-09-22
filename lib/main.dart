import 'package:app/pages/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const JawalGamesApp());
}

class JawalGamesApp extends StatelessWidget {
  const JawalGamesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JawalGames',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  final GlobalKey<RefreshIndicatorState> _refreshKey =
  GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(false) // zoom disable = faster rendering
      ..setBackgroundColor(const Color(0xff333131)) // webview bg color
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            // Inject JavaScript to hide footer only
            await _controller.runJavaScript("""
              // Hide footer completely
              var footer = document.querySelector('footer');
              if (footer) { footer.style.display = 'none'; }

              // Hide "You have Explored all the availible game" section if exists
              var exploreText = document.evaluate(
                "//*[contains(text(),'You have Explored all the availible game')]",
                document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null
              ).singleNodeValue;
              if (exploreText) {
                exploreText.parentElement.style.display = 'none';
              }
            """);
          },
          onNavigationRequest: (NavigationRequest request) {
            if (!request.url.contains('https://jawalgames.net/')) {
              _launchURL(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://jawalgames.net/'));
  }

  Future<void> _reloadWebView() async {
    await _controller.reload();
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch URL')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: RefreshIndicator(
          key: _refreshKey,
          onRefresh: _reloadWebView,
          child: WebViewWidget(controller: _controller),
        ),
      ),
    );
  }
}
