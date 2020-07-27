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
  void _editProfileModal(
    BuildContext ctx,
  ) {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
      elevation: 10,
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: EditProfile(),
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  void _editProfileImageModal(
    BuildContext ctx,
  ) {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
      elevation: 10,
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: EditProfileImage(),
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

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
                minExtent: 312,
                maxExtent: 312,
              ),
            ),
          ];
        },
        body: ProfileCategory(),
      ),
    );
  }
}
