import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:haber/data/constants.dart';
import 'package:haber/models/Firebase.dart';
import 'dart:convert';

import 'package:haber/models/News.dart';
import 'package:haber/models/User.dart';
import 'package:haber/requests/news_request.dart';
import 'package:haber/requests/user_request.dart';

class UserProvider with ChangeNotifier {
  UserProvider() {
    fetchUser();
  }

  User _user;

  List<News> _likedNews = List<News>();
  List<News> _dislikedNews = List<News>();
  List<News> _commentedNews = List<News>();
  String errorMessage;
  bool loading = true;
  bool adding = false;
  bool loadingMore = false;
  int sliderPage = 1;
  int listPage = 1;

  bool _loadingLikedNews = false, _loadingLikedNewsMore = false;
  bool _loadingDislikedNews = false, _loadingDislikedNewsMore = false;
  bool _loadingCommentedNews = false, _loadingCommentedNewsMore = false;

  bool get loadingLikedNews => _loadingLikedNews;
  bool get loadingLikedNewsMore => _loadingLikedNewsMore;
  bool get loadingDislikedNews => _loadingDislikedNews;
  bool get loadingDislikedNewsMore => _loadingDislikedNewsMore;
  bool get loadingCommentedNews => _loadingCommentedNews;
  bool get loadingCommentedNewsMore => _loadingCommentedNewsMore;

  set setLoadingLikedNews(bool value) {
    _loadingLikedNews = value;
  }

  set setLoadingLikedNewsMore(bool value) {
    _loadingLikedNewsMore = value;
  }

  set setLoadingDislikedNews(bool value) {
    _loadingDislikedNews = value;
  }

  set setLoadingDislikedNewsMore(bool value) {
    _loadingDislikedNewsMore = value;
  }

  set setLoadingCommentedNews(bool value) {
    _loadingCommentedNews = value;
  }

  set setLoadingCommentedNewsMore(bool value) {
    _loadingCommentedNewsMore = value;
  }

  //Liked news

  Future<void> fetchLikedNews(String search, bool isMore) async {
    print("slidergeldi");
    if (isMore)
      setLoadingLikedNewsMore = true;
    else
      setLoadingLikedNews = true;

    try {
      if (!isMore) sliderPage = 1;
      UserRequest()
          .fetchLikedNews((isMore ? (sliderPage + 1) : sliderPage), search)
          .then((data) {
        if (data.statusCode == 200) {
          List<News> news = (json.decode(data.body) as List)
              .map((data) => News.fromJson(data))
              .toList();

          if (isMore) {
            if (news.length > 0) {
              ++sliderPage;
            }
            _likedNews.addAll(news);
            setLoadingLikedNewsMore = false;
            notifyListeners();
          } else {
            //first page
            setLikedNews(news);
            setLoadingLikedNews = false;
            notifyListeners();
          }
        } else {
          Map<String, dynamic> result = json.decode(data.body);
          setMessage(result["error"]);
          setLoadingLikedNews = false;
          setLoadingLikedNewsMore = false;
        }
      });
    } catch (e) {}
  }

  void setLikedNews(value) {
    _likedNews = value;
    notifyListeners();
  }

  List<News> getLikedNews() {
    return _likedNews;
  }

  bool anyLikedNews() {
    return _likedNews != null ? _likedNews.length == 0 ? false : true : false;
  }

  int likedNewsLength() {
    return _likedNews != null ? _likedNews.length : 0;
  }

  //Disliked News

  static void LogPrint(Object object) async {
    int defaultPrintLength = 600;
    if (object == null || object.toString().length <= defaultPrintLength) {
      print(object);
    } else {
      String log = object.toString();
      int start = 0;
      int endIndex = defaultPrintLength;
      int logLength = log.length;
      int tmpLogLength = log.length;
      while (endIndex < logLength) {
        print(log.substring(start, endIndex));
        endIndex += defaultPrintLength;
        start += defaultPrintLength;
        tmpLogLength -= defaultPrintLength;
      }
      if (tmpLogLength > 0) {
        print(log.substring(start, logLength));
      }
    }
  }

  Future<void> fetchDislikedNews(String search, bool isMore) async {
    if (loadingDislikedNews || loadingDislikedNewsMore) return;

    if (isMore)
      setLoadingDislikedNewsMore = true;
    else
      setLoadingDislikedNews = true;

    try {
      if (!isMore) listPage = 1;
      UserRequest()
          .fetchDislikedNews((isMore ? (listPage + 1) : listPage), search)
          .then((data) {
        if (data.statusCode == 200) {
          List<News> news = (json.decode(data.body) as List)
              .map((data) => News.fromJson(data))
              .toList();

          if (isMore) {
            if (news.length > 0) {
              ++listPage;
            }
            _dislikedNews.addAll(news);
            setLoadingDislikedNewsMore = false;
            notifyListeners();
          } else {
            //first page
            setDislikedNews(news);
            setLoadingDislikedNews = false;
            notifyListeners();
          }
        } else {
          Map<String, dynamic> result = json.decode(data.body);
          setMessage(result["error"]);
          setLoadingDislikedNews = false;
          setLoadingDislikedNewsMore = false;
        }
      });
    } catch (e) {
      setLoadingDislikedNews = false;
      setLoadingDislikedNewsMore = false;
    }
  }

  void setDislikedNews(value) {
    _dislikedNews = value;
    notifyListeners();
  }

  List<News> getDislikedNews() {
    return _dislikedNews;
  }

  bool anyDislikedNews() {
    return (_dislikedNews != null && _dislikedNews.length > 0) ? true : false;
  }

  int dislikedNewsLength() {
    return _dislikedNews != null ? _dislikedNews.length : 0;
  }

  //Commented News

  Future<void> fetchCommentedNews(String search, bool isMore) async {
    if (loadingCommentedNews || loadingCommentedNewsMore) return;

    if (isMore)
      setLoadingCommentedNewsMore = true;
    else
      setLoadingCommentedNews = true;

    try {
      if (!isMore) listPage = 1;
      UserRequest()
          .fetchCommentedNews((isMore ? (listPage + 1) : listPage), search)
          .then((data) {
        print("data body ne " + data.body);
        print("data.statusCode " + data.statusCode.toString());

        if (data.statusCode == 200) {
          List<News> news = (json.decode(data.body) as List)
              .map((data) => News.fromJson(data))
              .toList();
          if (isMore) {
            if (news.length > 0) {
              ++listPage;
            }
            _commentedNews.addAll(news);
            setLoadingCommentedNewsMore = false;
            notifyListeners();
          } else {
            //first page
            setCommentedNews(news);
            setLoadingCommentedNews = false;
            notifyListeners();
          }
        } else {
          Map<String, dynamic> result = json.decode(data.body);
          setMessage(result["error"]);
          setLoadingCommentedNews = false;
          setLoadingCommentedNewsMore = false;
        }
      });
    } catch (e) {
      setLoadingCommentedNews = false;
      setLoadingCommentedNewsMore = false;
    }
  }

  void setCommentedNews(value) {
    _commentedNews = value;
    notifyListeners();
  }

  List<News> getCommentedNews() {
    return _commentedNews;
  }

  bool anyCommentedNews() {
    return (_commentedNews != null && _commentedNews.length > 0) ? true : false;
  }

  int commentedNewsLength() {
    return _commentedNews != null ? _commentedNews.length : 0;
  }

  // Profile

  User getUser() {
    return _user;
  }

  bool isUserExists() {
    return _user == null ? false : true;
  }

  setUser(User user) {
    _user = user;
  }

  Future<void> fetchUser() async {
    if (Constants.loggedIn && Firebase().getUser() != null) {
      try {
        UserRequest().getUserProfile().then((data) {
          print("gelen data profile photo " + data.body);
          if (data.statusCode == 200) {
            _user = User.fromJson(json.decode(data.body), "");
            notifyListeners();
          } else {
            print("error2" + data.statusCode.toString());
          }
        });
      } catch (e) {
        print("error");
      }
    } else {
      print("user not logged in");
    }
  }

  Future<void> changeProfilePhoto(String url) async {
    try {
      UserRequest().changeProfilePhoto(url).then((data) {
        print("gelen data profile photo " + data.body);
        if (data.statusCode == 200) {
          _user = User.fromJson(json.decode(data.body), "");
          notifyListeners();
        } else {
          print("error2" + data.statusCode.toString());
        }
      });
    } catch (e) {
      print("error");
    }
  }

  Future<void> editProfile(String name, String email) async {
    try {
      UserRequest().editProfile(name, email).then((data) {
        if (data.statusCode == 200) {
          _user = User.fromJson(json.decode(data.body), "");
          notifyListeners();
        } else {
          print("error2" + data.statusCode.toString());
        }
      });
    } catch (e) {
      print("error");
    }
  }

  // Others

  void setMessage(value) {
    errorMessage = value;
    notifyListeners();
  }

  String getMessage() {
    return errorMessage;
  }
}
