import 'package:flutter/material.dart';
import 'package:haber/app_theme.dart';
import 'package:haber/models/News.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Browser extends StatelessWidget {
  WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    News news = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          news.title,
          style: AppTheme.captionWhiteBig,
        ),
      ),
      body: WebView(
        initialUrl: news.link,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller = webViewController;
        },
      ),
    );
  }
}
