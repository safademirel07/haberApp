import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haber/app_theme.dart';
import 'package:haber/data/constants.dart';
import 'package:haber/data/sharedpref/shared_preference_helper.dart';
import 'package:haber/models/Firebase.dart';
import 'package:haber/models/User.dart';
import 'package:haber/providers/news_provider.dart';
import 'package:haber/providers/user_provider.dart';
import 'package:haber/widgets/others/custom_circle_avatar.dart';
import 'package:haber/widgets/user/edit_profile.dart';
import 'package:haber/widgets/user/edit_profile_image.dart';
import 'package:haber/widgets/others/full_screen_image.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

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

    String photoUrl =
        user.photoUrl == null ? Constants.defaultPhotoUrl : user.photoUrl;

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
                          onPressed: () {
                            logoutRequest(context);
                          },
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
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        FullScreenImage(photoUrl)));
                          },
                          child: Container(
                            margin: EdgeInsets.all(10.0),
                            child: CustomCircleAvatar(
                              heroTag: "profilFotografi",
                              animationDuration: 300,
                              radius: MediaQuery.of(context).size.height * 0.22,
                              imagePath: photoUrl,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            await DefaultCacheManager()
                                .removeFile(user.photoUrl);

                            _editProfileImageModal(context);
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

  void logoutRequest(BuildContext context) async {
    FirebaseAuth.instance.signOut();
    Provider.of<UserProvider>(context, listen: false).logoutRequest();
    Constants.loggedIn = false;
    Constants.anonymousLoggedIn = true;
    AuthResult authResult = await FirebaseAuth.instance.signInAnonymously();
    await SharedPreferenceHelper.setAnonymousID(authResult.user.uid);
    var firebase = Firebase();
    firebase.setUser(authResult.user, true);
    Provider.of<NewsProvider>(context, listen: false).setAnonymous = true;
    Navigator.pushReplacementNamed(
      context,
      "/home",
    );
  }

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
