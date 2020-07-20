import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:haber/models/NewsTest.dart';
import 'package:haber/providers/news_provider.dart';
import 'package:haber/widgets/news/news_detail.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

import 'package:webview_flutter/webview_flutter.dart';

List<NewsTest> news = List<NewsTest>();

class NewsSlider extends StatefulWidget {
  @override
  _NewsSliderState createState() => _NewsSliderState();
}

class _NewsSliderState extends State<NewsSlider> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    List<String> categories = List<String>();
    List<String> news_sites = List<String>();

    Future.microtask(
      () => Provider.of<NewsProvider>(context, listen: false).fetchListNews(
        "",
        categories,
        news_sites,
        false,
      ),
    ).then((value) {
      categories.add("5f135127c961bd0bb0ba82b7");
      Future.microtask(
        () => Provider.of<NewsProvider>(context, listen: false).fetchSliderNews(
          "",
          categories,
          news_sites,
          false,
        ),
      );
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text("haberApp"),
          ),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.filter_list),
                onPressed: () => {
                      print("test"),
                    })
          ],
        ),
        key: _scaffoldKey,
        body: (Provider.of<NewsProvider>(context).anySliderNews() &&
                Provider.of<NewsProvider>(context).anyListNews())
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
                    items: Provider.of<NewsProvider>(context).anySliderNews()
                        ? Provider.of<NewsProvider>(context)
                            .getSliderNews()
                            .map((item) => Container(
                                  child: Container(
                                    margin: EdgeInsets.all(5.0),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5.0)),
                                        child: Stack(
                                          children: <Widget>[
                                            Image.network(item.image,
                                                fit: BoxFit.cover,
                                                width: 1000.0),
                                            Positioned(
                                              bottom: 0.0,
                                              left: 0.0,
                                              right: 0.0,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Color.fromARGB(
                                                          200, 0, 0, 0),
                                                      Color.fromARGB(0, 0, 0, 0)
                                                    ],
                                                    begin:
                                                        Alignment.bottomCenter,
                                                    end: Alignment.topCenter,
                                                  ),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10.0,
                                                    horizontal: 20.0),
                                                child: Text(
                                                  item.title,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )),
                                  ),
                                ))
                            .toList()
                        : CircularProgressIndicator(),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: Provider.of<NewsProvider>(context)
                          .getListNews()
                          .length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          contentPadding: EdgeInsets.all(4),
                          leading: CachedNetworkImage(
                            imageUrl: Provider.of<NewsProvider>(context)
                                .getListNews()[index]
                                .image,
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
                          title: Text(
                            Provider.of<NewsProvider>(context)
                                .getListNews()[index]
                                .title,
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                          subtitle: Text(Provider.of<NewsProvider>(context)
                              .getListNews()[index]
                              .date),
                          trailing: Wrap(
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.chevron_right),
                                onPressed: () async {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => NewsDetail(
                                        Provider.of<NewsProvider>(context)
                                            .getListNews()[index]),
                                  ));
                                },
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ))
            : Container(
                child: IconButton(
                    icon: Icon(Icons.cached), onPressed: () => {print("test")}),
              ),
      ),
    );
  }
}

class WebViewLoad extends StatefulWidget {
  String title;
  String url;

  WebViewLoad(this.title, this.url);

  WebViewLoadUI createState() => WebViewLoadUI();
}

class WebViewLoadUI extends State<WebViewLoad> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: WebView(
          initialUrl: widget.url,
          javascriptMode: JavascriptMode.unrestricted,
        ));
  }
}
