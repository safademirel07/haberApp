import 'package:flutter/material.dart';
import 'package:haber/providers/comment_provider.dart';
import 'package:provider/provider.dart';

class AddComment extends StatefulWidget {
  String newsID;

  AddComment(this.newsID);

  @override
  _AddCommentState createState() => _AddCommentState();
}

class _AddCommentState extends State<AddComment> {
  final commentController = TextEditingController();

  sendComment() {
    Provider.of<CommentProvider>(context, listen: false)
        .addComment(widget.newsID, commentController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.black)),
      child: Container(
        margin: EdgeInsets.only(left: 8, right: 8),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          textBaseline: TextBaseline.ideographic,
          children: [
            Expanded(
              child: Container(
                child: TextField(
                  maxLines: 3,
                  controller: commentController,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Bir yorum yazın.',
                      alignLabelWithHint: true),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                sendComment();
              },
            )
          ],
        ),
      ),
    );
  }
}
