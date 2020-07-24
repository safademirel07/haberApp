import 'package:flutter/material.dart';
import 'package:haber/models/News.dart';
import 'package:haber/providers/news_provider.dart';
import 'package:haber/widgets/news/news_list_element.dart';
import 'package:haber/widgets/news/news_slider.dart';
import 'package:haber/widgets/user/profile_header.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    List<News> news =
        Provider.of<NewsProvider>(context, listen: true).anyListNews()
            ? Provider.of<NewsProvider>(context, listen: true).getListNews()
            : List<News>();

    return SafeArea(
      child: Scaffold(
          body: CustomScrollView(
        slivers: <Widget>[
          SliverPersistentHeader(
            pinned: false,
            floating: false,
            delegate: ProfileHeader(
              minExtent: 255.0,
              maxExtent: 255.0,
            ),
          ),
        ],
      )),
    );
  }
}
