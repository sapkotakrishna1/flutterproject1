import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  final String paymentUrl;

  const WebViewPage({Key? key, required this.paymentUrl}) : super(key: key);

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  @override
  void initState() {
    super.initState();
    // Initialize WebView
    WebView.platform =
        SurfaceAndroidWebView(); // To avoid deprecation warnings in Android
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: WebView(
        initialUrl: widget.paymentUrl,
        javascriptMode: JavascriptMode
            .unrestricted, // Enable JavaScript for dynamic content
        onWebViewCreated: (WebViewController webViewController) {},
      ),
    );
  }
}
