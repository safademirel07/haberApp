import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:haber/app_theme.dart';
import 'package:haber/data/constants.dart';
import 'package:haber/models/Firebase.dart';
import 'package:haber/models/NewsTest.dart';
import 'package:haber/providers/news_provider.dart';
import 'package:haber/widgets/news/careousel_slider.dart';
import 'package:haber/widgets/news/category_list.dart';
import 'package:haber/widgets/news/news_detail.dart';
import 'package:haber/widgets/news/news_list.dart';
import 'package:haber/widgets/news/news_list_element.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

import 'package:webview_flutter/webview_flutter.dart';

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

List<NewsTest> news = List<NewsTest>();

class NewsSlider implements SliverPersistentHeaderDelegate {
  NewsSlider({
    this.minExtent,
    @required this.maxExtent,
  });
  final double minExtent;
  final double maxExtent;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 8, top: 8),
                child: Text(
                  "Son Dakika",
                  style: AppTheme.headline,
                ),
              ),
              Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.search,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        "/search",
                      );
                    },
                  ),
                ],
              )
            ],
          ),
        ),
        Divider(
          color: Colors.black,
        ),
        CareouselSlider(),
      ],
    );
  }

  double titleOpacity(double shrinkOffset) {
    // simple formula: fade out text as soon as shrinkOffset > 0
    return 1.0 - max(0.0, shrinkOffset) / maxExtent;
    // more complex formula: starts fading out text when shrinkOffset > minExtent
    //return 1.0 - max(0.0, (shrinkOffset - minExtent)) / (maxExtent - minExtent);
  }

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  @override
  FloatingHeaderSnapConfiguration get snapConfiguration => null;

  @override
  OverScrollHeaderStretchConfiguration get stretchConfiguration => null;
}
