import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haber/models/News.dart';
import 'package:haber/providers/news_provider.dart';
import 'package:haber/widgets/news/category_list.dart';
import 'package:haber/widgets/others/custom_circle_avatar.dart';
import 'package:haber/widgets/user/change_password.dart';
import 'package:haber/widgets/user/edit_profile.dart';
import 'package:haber/widgets/user/edit_profile_image.dart';
import 'package:haber/widgets/user/profile_category.dart';
import 'package:haber/widgets/user/profile_header.dart';
import 'package:provider/provider.dart';

import '../../app_theme.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverPersistentHeader(
              pinned: false,
              floating: false,
              delegate: ProfileHeader(
                minExtent: MediaQuery.of(context).size.height * 0.43,
                maxExtent: MediaQuery.of(context).size.height * 0.43,
              ),
            ),
          ];
        },
        body: ProfileCategory(),
      ),
    );
  }
}
