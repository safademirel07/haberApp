import 'package:flutter/material.dart';
import 'package:haber/models/Comment.dart';

class CommentElement extends StatelessWidget {
  final Comment comment;

  CommentElement(this.comment);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            child: Divider(
              height: 1,
              thickness: 2,
              color: Colors.grey[500],
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
                    style: TextStyle(
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
    );
  }
}
