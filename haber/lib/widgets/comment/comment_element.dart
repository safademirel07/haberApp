import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:haber/models/Comment.dart';
import 'package:haber/widgets/others/custom_circle_avatar.dart';
import 'package:haber/widgets/others/full_screen_image.dart';
import 'package:intl/intl.dart';

class CommentElement extends StatelessWidget {
  final Comment comment;

  CommentElement(this.comment);

  @override
  Widget build(BuildContext context) {
    String userPhoto =
        (comment.userPhoto == null || comment.userPhoto.length == 0)
            ? 'https://s3.amazonaws.com/37assets/svn/765-default-avatar.png'
            : comment.userPhoto;

    DateTime date = DateTime.fromMillisecondsSinceEpoch(comment.date * 1000);
    String formattedDate = DateFormat('dd MMMM E HH:mm', "tr").format(date);

    return InkWell(
      onLongPress: () {
        if (comment.isOwner)
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Sil"),
                  content: Text("Bu gönderiyi silmek istediğine emin misin?"),
                  actions: [
                    FlatButton(
                      child: Text("Evet"),
                    ),
                    FlatButton(
                      child: Text("Hayır"),
                    )
                  ],
                );
              });
        else
          print("senin degil comment");
        print("long press");
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 10),
        color: Colors.grey[100],
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FullScreenImage(
                                  userPhoto, userPhoto + comment.sId)));
                    },
                    child: CustomCircleAvatar(
                      heroTag: userPhoto + comment.sId,
                      animationDuration: 300,
                      radius: 50,
                      imagePath: userPhoto,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Container(
                                margin: const EdgeInsets.only(top: 5),
                                child: new Text(
                                  comment.userName,
                                  style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                      color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          if (comment.isOwner)
                            Column(
                              children: <Widget>[
                                InkWell(
                                  child: Container(
                                    margin:
                                        const EdgeInsets.only(top: 4, right: 8),
                                    child: Icon(
                                      FontAwesomeIcons.asterisk,
                                      size: 10,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 5),
                        child: new Text(
                          formattedDate,
                          style: GoogleFonts.montserrat(
                              fontStyle: FontStyle.italic,
                              fontSize: 13.0,
                              color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              child: Divider(
                height: 1,
                thickness: 2,
                color: Colors.black,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Flex(
                direction: Axis.horizontal,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      comment.text,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                      ),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
