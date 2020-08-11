import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:haber/data/constants.dart';
import 'package:haber/models/Comment.dart';
import 'dart:convert';

import 'package:haber/models/News.dart';
import 'package:haber/requests/comment_request.dart';
import 'package:haber/requests/search_request.dart';
import 'package:provider/provider.dart';

class CommentProvider with ChangeNotifier {
  List<Comment> _comments = List<Comment>();

  bool _isLoading = false, _isLoadingMore = false;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;

  set setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  set setLoadingMore(bool value) {
    _isLoadingMore = value;
    notifyListeners();
  }

  int page = 1;

  Future<void> fetchListNews(String newsID, bool isMore) async {
    if (isLoadingMore) return;

    if (isMore)
      setLoadingMore = true;
    else
      setLoading = true;

    try {
      if (!isMore) page = 1;
      CommentRequest()
          .getComment((isMore ? (page + 1) : page), newsID)
          .then((data) {
        if (data.statusCode == 200) {
          List<Comment> news = (json.decode(data.body) as List)
              .map((data) => Comment.fromJson(data))
              .toList();

          if (isMore) {
            if (news.length > 0) {
              ++page;
            }
            _comments.addAll(news);
            setLoading = false;
            setLoadingMore = false;
            notifyListeners();
          } else {
            //first page
            setComment(news);
            setLoading = false;
            setLoadingMore = false;
            notifyListeners();
          }
        } else {
          Map<String, dynamic> result = json.decode(data.body);
          setLoading = false;
          setLoadingMore = false;
        }
      });
    } catch (e) {
      setLoading = false;
      setLoadingMore = false;
    }
  }

  void setComment(value) {
    _comments = value;
    notifyListeners();
  }

  List<Comment> getComments() {
    return _comments;
  }

  bool anyComment() {
    return (_comments != null && _comments.length > 0) ? true : false;
  }

  int commentLength() {
    return _comments != null ? _comments.length : 0;
  }

  Future<void> addComment(String newsID, String comment) async {
    try {
      CommentRequest().addComment(newsID, comment).then((data) {
        if (data.statusCode == 200) {
          Comment returnData = Comment.fromJson(json.decode(data.body));
          _comments.add(returnData);
          notifyListeners();
        } else {
          print("error2" + data.statusCode.toString());
        }
      });
    } catch (e) {
      print("error");
    }
  }
}
