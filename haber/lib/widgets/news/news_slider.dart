import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:haber/models/NewsTest.dart';
import 'package:http/http.dart' as http;
import 'package:webfeed/domain/rss_feed.dart';

import 'dart:convert';

List<NewsTest> news = List<NewsTest>();

final List<Widget> imageSliders = news
    .map((item) => Container(
          child: Container(
            margin: EdgeInsets.all(5.0),
            child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                child: Stack(
                  children: <Widget>[
                    Image.network(item.image, fit: BoxFit.cover, width: 1000.0),
                    Positioned(
                      bottom: 0.0,
                      left: 0.0,
                      right: 0.0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(200, 0, 0, 0),
                              Color.fromARGB(0, 0, 0, 0)
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        child: Text(
                          item.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
          ),
        ))
    .toList();

class NewsSlider extends StatefulWidget {
  @override
  _NewsSliderState createState() => _NewsSliderState();
}

class _NewsSliderState extends State<NewsSlider> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    test();
  }

  Future<http.Response> fetchNews() async {
    return http
        .get("http://10.0.3.2:3000/parser/sabah", headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });
  }

  void test() {
    setState(() {
      fetchNews().then((data) {
        print("data" + data.statusCode.toString());

        List<NewsTest> newstest = (json.decode(data.body) as List)
            .map((data) => NewsTest.fromJson(data))
            .toList();

        news = newstest;
        print("newstest" + newstest.toString());
      });
    });
  }

  var client = new http.Client();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text("haberApp"),
          ),
        ),
        key: _scaffoldKey,
        body: news.length != 0
            ? Container(
                child: Column(
                children: <Widget>[
                  CarouselSlider(
                    options: CarouselOptions(
                      onPageChanged: (index, reason) =>
                          print("index ne " + index.toString()),
                      enableInfiniteScroll: false,
                      autoPlay: true,
                      aspectRatio: 2.0,
                      enlargeCenterPage: true,
                    ),
                    items: imageSliders,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: news.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          contentPadding: EdgeInsets.all(4),
                          leading: CachedNetworkImage(
                            imageUrl: news[index].image,
                            imageBuilder: (context, imageProvider) => Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                image: DecorationImage(
                                    image: imageProvider, fit: BoxFit.cover),
                              ),
                            ),
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                          title: Text(news[index].title),
                        );
                      },
                    ),
                  ),
                ],
              ))
            : Container(
                child: IconButton(
                  icon: Icon(Icons.cached),
                  onPressed: () => test(),
                ),
              ),
      ),
    );
  }
}
