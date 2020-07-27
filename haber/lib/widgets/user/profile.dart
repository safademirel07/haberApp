import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haber/models/News.dart';
import 'package:haber/providers/news_provider.dart';
import 'package:haber/widgets/others/custom_circle_avatar.dart';
import 'package:haber/widgets/user/change_password.dart';
import 'package:haber/widgets/user/edit_profile.dart';
import 'package:haber/widgets/user/edit_profile_image.dart';
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
    return SafeArea(
      child: Scaffold(
        body: Column(
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
                            imagePath:
                                'https://s3.amazonaws.com/37assets/svn/765-default-avatar.png'),
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
                        "Safa Demirel",
                        style: AppTheme.body2,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      InkWell(
                        onTap: () {
                          _editProfileModal(context);
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
        ),
      ),
    );
  }
}
