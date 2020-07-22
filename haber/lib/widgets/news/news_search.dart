import 'package:flutter/material.dart';

class NewsSearch extends StatefulWidget {
  @override
  _NewsSearchState createState() => _NewsSearchState();
}

class _NewsSearchState extends State<NewsSearch> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Column(
            children: <Widget>[
              Text("Search"),
            ],
          ),
        ),
      ),
    );
  }
}
