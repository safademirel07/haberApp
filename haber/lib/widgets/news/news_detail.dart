import 'package:flutter/material.dart';
import 'package:haber/models/News.dart';

class NewsDetail extends StatefulWidget {
  News news;

  NewsDetail(this.news);

  @override
  _NewsDetailState createState() => _NewsDetailState();
}

class _NewsDetailState extends State<NewsDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.news.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Text(widget.news.body),
          ],
        ),
      ),
    );
  }
}
