import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haber/app_theme.dart';
import 'package:haber/data/constants.dart';
import 'package:haber/models/Firebase.dart';
import 'package:haber/models/NewsTest.dart';
import 'package:haber/models/User.dart';
import 'package:haber/providers/news_provider.dart';
import 'package:haber/providers/user_provider.dart';
import 'package:haber/widgets/news/careousel_slider.dart';
import 'package:haber/widgets/news/category_list.dart';
import 'package:haber/widgets/news/news_detail.dart';
import 'package:haber/widgets/news/news_list.dart';
import 'package:haber/widgets/news/news_list_element.dart';
import 'package:haber/widgets/others/custom_circle_avatar.dart';
import 'package:haber/widgets/user/edit_profile.dart';
import 'package:haber/widgets/user/edit_profile_image.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

import 'package:webview_flutter/webview_flutter.dart';

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ProfileHeader implements SliverPersistentHeaderDelegate {
  ProfileHeader({
    this.minExtent,
    @required this.maxExtent,
  });
  final double minExtent;
  final double maxExtent;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    User user = Provider.of<UserProvider>(context, listen: true).getUser();

    print("user.photoUrl" + user.photoUrl);

    return user == null
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 8, top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 8, top: 8),
                      child: Text(
                        "Profil",
                        style: AppTheme.headline,
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(
                            FontAwesomeIcons.signOutAlt,
                            color: Colors.black,
                          ),
                          onPressed: () {},
                        )
                      ],
                    )
                  ],
                ),
              ),
              Divider(
                color: Colors.black,
              ),
              Center(
                child: Column(
                  children: <Widget>[
                    Stack(
                      alignment: Alignment.topRight,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.all(10.0),
                          child: CustomCircleAvatar(
                              animationDuration: 300,
                              radius: 180,
                              imagePath: (user == null ||
                                      user.photoUrl.length <= 0)
                                  ? 'https://s3.amazonaws.com/37assets/svn/765-default-avatar.png'
                                  : user.photoUrl),
                        ),
                        InkWell(
                          onTap: () {
                            _editProfileImageModal(context);
                            print("edit profile photo");
                          },
                          child: Icon(Icons.add_a_photo),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          user.name,
                          style: AppTheme.body2,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        InkWell(
                          onTap: () {
                            _editProfileModal(context, user);
                            print("edit profile photo");
                          },
                          child: Icon(Icons.edit),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(
                color: Colors.black,
              ),
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

  void _editProfileModal(BuildContext ctx, User user) {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
      elevation: 10,
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: EditProfile(user),
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
}
