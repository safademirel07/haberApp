import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:haber/data/constants.dart';
import 'package:haber/data/sharedpref/shared_preference_helper.dart';
import 'package:haber/models/Firebase.dart';
import 'dart:convert';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:haber/models/News.dart';
import 'package:haber/models/User.dart';
import 'package:haber/requests/news_request.dart';
import 'package:haber/requests/user_request.dart';
import 'dart:math';

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
  int likedPage = 1;
  int dislikedPage = 1;
  int commentPage = 1;

  int getNewsLikedListIndex(String id) {
    return _likedNews == null
        ? -1
        : _likedNews.indexWhere((news) => news.sId == id);
  }

  int getNewsDislikedListIndex(String id) {
    return _dislikedNews == null
        ? -1
        : _dislikedNews.indexWhere((news) => news.sId == id);
  }

  int getNewsCommentedListIndex(String id) {
    return _commentedNews == null
        ? -1
        : _commentedNews.indexWhere((news) => news.sId == id);
  }

  void updateAllLists(String id, News returnNews) {
    News fromLiked, fromDisliked, fromCommented;

    if (getNewsLikedListIndex(id) != -1) {
      fromLiked = _likedNews[getNewsLikedListIndex(id)];
    }

    if (getNewsDislikedListIndex(id) != -1) {
      fromDisliked = _dislikedNews[getNewsDislikedListIndex(id)];
    }

    if (getNewsCommentedListIndex(id) != -1) {
      fromCommented = _commentedNews[getNewsCommentedListIndex(id)];
    }

    if (fromLiked != null) {
      fromLiked.likes = returnNews.likes;
      fromLiked.dislikes = returnNews.dislikes;
      fromLiked.viewers = returnNews.viewers;
      fromLiked.isLiked = returnNews.isLiked;
      fromLiked.isDisliked = returnNews.isDisliked;
      fromLiked.uniqueViews = returnNews.uniqueViews;
      fromLiked.isFavorited = returnNews.isFavorited;
    }

    if (fromDisliked != null) {
      fromDisliked.likes = returnNews.likes;
      fromDisliked.dislikes = returnNews.dislikes;
      fromDisliked.viewers = returnNews.viewers;
      fromDisliked.isLiked = returnNews.isLiked;
      fromDisliked.isDisliked = returnNews.isDisliked;
      fromDisliked.uniqueViews = returnNews.uniqueViews;
      fromDisliked.isFavorited = returnNews.isFavorited;
    }

    if (fromCommented != null) {
      fromCommented.likes = returnNews.likes;
      fromCommented.dislikes = returnNews.dislikes;
      fromCommented.viewers = returnNews.viewers;
      fromCommented.isLiked = returnNews.isLiked;
      fromCommented.isDisliked = returnNews.isDisliked;
      fromCommented.uniqueViews = returnNews.uniqueViews;
      fromCommented.isFavorited = returnNews.isFavorited;
    }
    notifyListeners();
  }

  bool _loadingLikedNews = true, _loadingLikedNewsMore = false;
  bool _loadingDislikedNews = true, _loadingDislikedNewsMore = false;
  bool _loadingCommentedNews = true, _loadingCommentedNewsMore = false;

  bool get loadingLikedNews => _loadingLikedNews;
  bool get loadingLikedNewsMore => _loadingLikedNewsMore;
  bool get loadingDislikedNews => _loadingDislikedNews;
  bool get loadingDislikedNewsMore => _loadingDislikedNewsMore;
  bool get loadingCommentedNews => _loadingCommentedNews;
  bool get loadingCommentedNewsMore => _loadingCommentedNewsMore;

  set setLoadingLikedNews(bool value) {
    _loadingLikedNews = value;
    notifyListeners();
  }

  set setLoadingLikedNewsMore(bool value) {
    _loadingLikedNewsMore = value;
    notifyListeners();
  }

  set setLoadingDislikedNews(bool value) {
    _loadingDislikedNews = value;
    notifyListeners();
  }

  set setLoadingDislikedNewsMore(bool value) {
    _loadingDislikedNewsMore = value;
    notifyListeners();
  }

  set setLoadingCommentedNews(bool value) {
    _loadingCommentedNews = value;
    notifyListeners();
  }

  set setLoadingCommentedNewsMore(bool value) {
    _loadingCommentedNewsMore = value;
    notifyListeners();
  }

  //Liked news

  Future<void> fetchLikedNews(String search, bool isMore) async {
    if (loadingLikedNewsMore) return;
    if (isMore)
      setLoadingLikedNewsMore = true;
    else
      setLoadingLikedNews = true;

    try {
      if (!isMore) likedPage = 1;
      UserRequest()
          .fetchLikedNews((isMore ? (likedPage + 1) : likedPage), search)
          .then((data) {
        if (data.statusCode == 200) {
          //LogPrint("databody " + data.body);
          List<News> news = (json.decode(data.body) as List)
              .map((data) => News.fromJson(data))
              .toList();

          if (isMore) {
            if (news.length > 0) {
              ++likedPage;
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
    if (loadingDislikedNewsMore) return;

    if (isMore)
      setLoadingDislikedNewsMore = true;
    else
      setLoadingDislikedNews = true;

    try {
      if (!isMore) dislikedPage = 1;
      UserRequest()
          .fetchDislikedNews(
              (isMore ? (dislikedPage + 1) : dislikedPage), search)
          .then((data) {
        if (data.statusCode == 200) {
          List<News> news = (json.decode(data.body) as List)
              .map((data) => News.fromJson(data))
              .toList();

          if (isMore) {
            if (news.length > 0) {
              ++dislikedPage;
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
      if (!isMore) commentPage = 1;
      UserRequest()
          .fetchCommentedNews(
              (isMore ? (commentPage + 1) : commentPage), search)
          .then((data) {
        if (data.statusCode == 200) {
          List<News> news = (json.decode(data.body) as List)
              .map((data) => News.fromJson(data))
              .toList();
          if (isMore) {
            if (news.length > 0) {
              ++commentPage;
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

  Future<bool> logoutRequest() async {
    UserRequest().logoutRequest().then((data) {
      if (data != null) {
        SharedPreferenceHelper.setAuthToken("");
        SharedPreferenceHelper.setUID("");
        SharedPreferenceHelper.setPassword("");
        SharedPreferenceHelper.setUser("");
        FirebaseAuth.instance.signOut();
        Constants.loggedIn = false;
        _user = null;
        notifyListeners();
      }
    });
  }

  Future<void> fetchUser() async {
    if (Constants.loggedIn &&
        Firebase().getUser() != null &&
        Constants.anonymousLoggedIn == false) {
      try {
        UserRequest().getUserProfile().then((data) {
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
      UserRequest().changeProfilePhoto(url).then((data) async {
        if (data.statusCode == 200) {
          _user = User.fromJson(json.decode(data.body), "");
          await DefaultCacheManager()
              .removeFile(_user.photoUrl); //invalidate old image
          Random random = new Random();
          _user.photoUrl += "&new=id_" +
              random
                  .nextInt(100000)
                  .toString(); //give random id , because if it's same url it doesnt rebuild.
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
