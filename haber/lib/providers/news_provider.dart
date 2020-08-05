import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:haber/data/constants.dart';
import 'dart:convert';

import 'package:haber/models/News.dart';
import 'package:haber/requests/news_request.dart';

class NewsProvider with ChangeNotifier {
  static List<String> _selectedNewsSites = List<String>();

  NewsProvider() {
    _selectedNewsSites = Constants.selectedNewsSites;
  }

  void setSelectedNewsSites() {
    _selectedNewsSites = Constants.selectedNewsSites;
    _requiredToFetchAgain = true;
    notifyListeners();
  }

  List<String> getSelectedNewsSites() {
    return _selectedNewsSites;
  }

  List<News> _sliderNews = List<News>();
  List<News> _listNews = List<News>();
  List<News> _favoriteNews = List<News>();
  String errorMessage;
  bool loading = true;
  bool adding = false;
  bool loadingMore = false;
  int sliderPage = 1;
  int listPage = 1;

  bool _isAnonymous = true;
  bool get isAnonymous => _isAnonymous;

  set setAnonymous(bool value) {
    _isAnonymous = value;
    notifyListeners();
  }

  void clearListNews() {
    _listNews = List<News>();
    notifyListeners();
  }

  bool _requiredToFetchAgain = false;
  bool _requiredToFetchAgainFavorites = false;

  bool _loadingSliderNews = false, _loadingSliderNewsMore = false;
  bool _loadingListNews = true, _loadingListNewsMore = false;
  bool _loadingFavoriteNews = true, _loadingFavoriteNewsMore = false;

  bool get loadingSliderNews => _loadingSliderNews;
  bool get loadingSliderNewsMore => _loadingSliderNewsMore;
  bool get loadingListNews => _loadingListNews;
  bool get loadingListNewsMore => _loadingListNewsMore;
  bool get loadingFavoriteNews => _loadingFavoriteNews;
  bool get loadingFavoriteNewsMore => _loadingFavoriteNewsMore;

  bool get requiredToFetchAgain => _requiredToFetchAgain;

  set setrequiredToFetchAgain(bool value) {
    _requiredToFetchAgain = value;
    notifyListeners();
  }

  bool get requiredToFetchAgainFavorites => _requiredToFetchAgainFavorites;

  set setRequiredToFetchAgainFavorites(bool value) {
    _requiredToFetchAgainFavorites = value;
    notifyListeners();
  }

  set setLoadingSliderNews(bool value) {
    _loadingSliderNews = value;
    notifyListeners();
  }

  set setLoadingSliderNewsMore(bool value) {
    _loadingSliderNewsMore = value;
    notifyListeners();
  }

  set setLoadingListNews(bool value) {
    _loadingListNews = value;
    notifyListeners();
  }

  set setLoadingListNewsMore(bool value) {
    _loadingListNewsMore = value;
    notifyListeners();
  }

  set setLoadingFavoriteNews(bool value) {
    _loadingFavoriteNews = value;
    notifyListeners();
  }

  set setLoadingFavoriteNewsMore(bool value) {
    _loadingFavoriteNewsMore = value;
    notifyListeners();
  }

  //Slider News

  Future<void> fetchSliderNews(List<String> sites, bool isMore) async {
    if (isMore)
      setLoadingSliderNewsMore = true;
    else
      setLoadingSliderNews = true;

    try {
      if (!isMore) sliderPage = 1;
      NewsRequest()
          .fetchNewsSlider((isMore ? (sliderPage + 1) : sliderPage), sites)
          .then((data) {
        if (data.statusCode == 200) {
          List<News> news = (json.decode(data.body) as List)
              .map((data) => News.fromJson(data))
              .toList();

          if (isMore) {
            if (news.length > 0) {
              ++sliderPage;
            }
            _sliderNews.addAll(news);
            setLoadingSliderNewsMore = false;
            notifyListeners();
          } else {
            //first page
            setSliderNews(news);
            setLoadingSliderNews = false;
            notifyListeners();
          }
        } else {
          Map<String, dynamic> result = json.decode(data.body);
          setMessage(result["error"]);
          setLoadingSliderNews = false;
          setLoadingSliderNewsMore = false;
        }
      });
    } catch (e) {}
  }

  void setSliderNews(value) {
    _sliderNews = value;
    notifyListeners();
  }

  List<News> getSliderNews() {
    return _sliderNews;
  }

  bool anySliderNews() {
    return _sliderNews != null ? _sliderNews.length == 0 ? false : true : false;
  }

  int sliderNewsLength() {
    return _sliderNews != null ? _sliderNews.length : 0;
  }

  //List News

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

  Future<void> fetchListNews(String search, List<String> categories,
      List<String> sites, bool isMore) async {
    print("burasi bir" + loadingListNews.toString());
    print("burasi bir" + loadingListNewsMore.toString());
    if (loadingListNewsMore) return;

    print("burasi iki");

    if (isMore)
      setLoadingListNewsMore = true;
    else
      setLoadingListNews = true;

    print("fetchlistnews");

    try {
      if (!isMore) listPage = 1;
      NewsRequest()
          .fetchNewsList(
              (isMore ? (listPage + 1) : listPage), search, categories, sites)
          .then((data) {
        if (data.statusCode == 200) {
          List<News> news = (json.decode(data.body) as List)
              .map((data) => News.fromJson(data))
              .toList();

          if (isMore) {
            if (news.length > 0) {
              ++listPage;
            }
            _listNews.addAll(news);
            setLoadingListNews = false;
            setLoadingListNewsMore = false;
            notifyListeners();
          } else {
            //first page
            setListNews(news);
            setLoadingListNews = false;
            setLoadingListNewsMore = false;
            notifyListeners();
          }
        } else {
          Map<String, dynamic> result = json.decode(data.body);
          setMessage(result["error"]);
          setLoadingListNews = false;
          setLoadingListNewsMore = false;
        }
      });
    } catch (e) {
      setLoadingListNews = false;
      setLoadingListNewsMore = false;
    }
  }

  void setListNews(value) {
    _listNews = value;
    notifyListeners();
  }

  List<News> getListNews() {
    return _listNews;
  }

  bool anyListNews() {
    return (_listNews != null && _listNews.length > 0) ? true : false;
  }

  int listNewsLength() {
    return _listNews != null ? _listNews.length : 0;
  }

  // Favorite News//

  //List News

  Future<void> fetchFavoriteNews(String search, bool isMore) async {
    if (loadingFavoriteNewsMore) return;

    if (isMore)
      setLoadingFavoriteNewsMore = true;
    else
      setLoadingFavoriteNews = true;

    try {
      if (!isMore) listPage = 1;
      NewsRequest()
          .fetchNewsFavorite((isMore ? (listPage + 1) : listPage), search)
          .then((data) {
        if (data.statusCode == 200) {
          List<News> news = (json.decode(data.body) as List)
              .map((data) => News.fromJson(data))
              .toList();
          if (isMore) {
            if (news.length > 0) {
              ++listPage;
            }
            _favoriteNews.addAll(news);
            setLoadingFavoriteNewsMore = false;
            notifyListeners();
          } else {
            //first page
            setFavoriteNews(news);
            setLoadingFavoriteNews = false;
            notifyListeners();
          }
        } else {
          Map<String, dynamic> result = json.decode(data.body);
          setMessage(result["error"]);
          setLoadingFavoriteNews = false;
          setLoadingFavoriteNewsMore = false;
        }
      });
    } catch (e) {
      setLoadingFavoriteNews = false;
      setLoadingFavoriteNewsMore = false;
    }
  }

  Future<void> fetchAnonymousFavoriteNews(String favorites, bool isMore) async {
    if (loadingFavoriteNewsMore) return;

    if (isMore)
      setLoadingFavoriteNewsMore = true;
    else
      setLoadingFavoriteNews = true;

    try {
      if (!isMore) listPage = 1;
      NewsRequest()
          .fetchNewsAnonymousFavorite(
              (isMore ? (listPage + 1) : listPage), favorites)
          .then((data) {
        print("gelen data body " + data.body);
        if (data.statusCode == 200) {
          List<News> news = (json.decode(data.body) as List)
              .map((data) => News.fromJson(data))
              .toList();
          if (isMore) {
            if (news.length > 0) {
              ++listPage;
            }
            _favoriteNews.addAll(news);
            setLoadingFavoriteNewsMore = false;
            notifyListeners();
          } else {
            //first page
            setFavoriteNews(news);
            setLoadingFavoriteNews = false;
            notifyListeners();
          }
        } else {
          Map<String, dynamic> result = json.decode(data.body);
          setMessage(result["error"]);
          setLoadingFavoriteNews = false;
          setLoadingFavoriteNewsMore = false;
        }
      });
    } catch (e) {
      setLoadingFavoriteNews = false;
      setLoadingFavoriteNewsMore = false;
    }
  }

  void setFavoriteNews(value) {
    _favoriteNews = value;
    notifyListeners();
  }

  List<News> getFavoriteNews() {
    return _favoriteNews;
  }

  bool anyFavoriteNews() {
    return (_favoriteNews != null && _favoriteNews.length > 0) ? true : false;
  }

  int favoriteNewsLength() {
    return _favoriteNews != null ? _favoriteNews.length : 0;
  }

  // Like, dislike, view

  int getNewsSliderIndex(String id) {
    return _sliderNews == null
        ? -1
        : _sliderNews.indexWhere((news) => news.sId == id);
  }

  int getNewsListIndex(String id) {
    return _listNews == null
        ? -1
        : _listNews.indexWhere((news) => news.sId == id);
  }

  int getNewsFavoriteIndex(String id) {
    return _favoriteNews == null
        ? -1
        : _favoriteNews.indexWhere((news) => news.sId == id);
  }

  Future<void> likeNews(String id) async {
    try {
      NewsRequest().likeNews(id).then((data) {
        if (data.statusCode == 200) {
          News returnData = News.fromJson(json.decode(data.body));

          News fromSlider, fromList, favoriteList;

          if (getNewsSliderIndex(id) != -1) {
            fromSlider = _sliderNews[getNewsSliderIndex(id)];
          }

          if (getNewsListIndex(id) != -1) {
            fromList = _listNews[getNewsListIndex(id)];
          }

          if (getNewsFavoriteIndex(id) != -1) {
            favoriteList = _favoriteNews[getNewsFavoriteIndex(id)];
          }

          if (fromSlider != null) {
            fromSlider.likes = returnData.likes;
            fromSlider.dislikes = returnData.dislikes;
            fromSlider.viewers = returnData.viewers;
            fromSlider.isLiked = returnData.isLiked;
            fromSlider.isDisliked = returnData.isDisliked;
          }

          if (fromList != null) {
            fromList.likes = returnData.likes;
            fromList.dislikes = returnData.dislikes;
            fromList.viewers = returnData.viewers;
            fromList.isLiked = returnData.isLiked;
            fromList.isDisliked = returnData.isDisliked;
          }

          if (favoriteList != null) {
            favoriteList.likes = returnData.likes;
            favoriteList.dislikes = returnData.dislikes;
            favoriteList.viewers = returnData.viewers;
            favoriteList.isLiked = returnData.isLiked;
            favoriteList.isDisliked = returnData.isDisliked;
          }

          notifyListeners();
        } else {
          print("error2" + data.statusCode.toString());
        }
      });
    } catch (e) {
      print("error");
    }
  }

  Future<void> dislikeNews(String id) async {
    try {
      NewsRequest().dislikeNews(id).then((data) {
        if (data.statusCode == 200) {
          News returnData = News.fromJson(json.decode(data.body));

          News fromSlider, fromList, favoriteList;

          if (getNewsSliderIndex(id) != -1) {
            fromSlider = _sliderNews[getNewsSliderIndex(id)];
          }

          if (getNewsListIndex(id) != -1) {
            fromList = _listNews[getNewsListIndex(id)];
          }

          if (getNewsFavoriteIndex(id) != -1) {
            favoriteList = _favoriteNews[getNewsFavoriteIndex(id)];
          }
          if (fromSlider != null) {
            fromSlider.likes = returnData.likes;
            fromSlider.dislikes = returnData.dislikes;
            fromSlider.viewers = returnData.viewers;
            fromSlider.isLiked = returnData.isLiked;
            fromSlider.isDisliked = returnData.isDisliked;
          }

          if (fromList != null) {
            fromList.likes = returnData.likes;
            fromList.dislikes = returnData.dislikes;
            fromList.viewers = returnData.viewers;
            fromList.isLiked = returnData.isLiked;
            fromList.isDisliked = returnData.isDisliked;
          }

          if (favoriteList != null) {
            favoriteList.likes = returnData.likes;
            favoriteList.dislikes = returnData.dislikes;
            favoriteList.viewers = returnData.viewers;
            favoriteList.isLiked = returnData.isLiked;
            favoriteList.isDisliked = returnData.isDisliked;
          }

          notifyListeners();
        } else {
          print("error2" + data.statusCode.toString());
        }
      });
    } catch (e) {
      print("error");
    }
  }

  Future<void> favoriteNews(String id) async {
    try {
      NewsRequest().favoriteNews(id).then((data) {
        if (data.statusCode == 200) {
          News returnData = News.fromJson(json.decode(data.body));

          News fromSlider, fromList, favoriteList;

          if (getNewsSliderIndex(id) != -1) {
            fromSlider = _sliderNews[getNewsSliderIndex(id)];
          }

          if (getNewsListIndex(id) != -1) {
            fromList = _listNews[getNewsListIndex(id)];
          }

          if (getNewsFavoriteIndex(id) != -1) {
            favoriteList = _favoriteNews[getNewsFavoriteIndex(id)];
          }
          if (fromSlider != null) {
            fromSlider.isFavorited = returnData.isFavorited;
          }

          if (fromList != null) {
            fromList.isFavorited = returnData.isFavorited;
          }

          if (favoriteList != null) {
            favoriteList.isFavorited = returnData.isFavorited;
          }

          notifyListeners();
        } else {
          print("error2" + data.statusCode.toString());
        }
      });
    } catch (e) {
      print("error");
    }
  }

  Future<void> viewNews(String id) async {
    try {
      NewsRequest().viewNews(id).then((data) {
        if (data.statusCode == 200) {
          News returnData = News.fromJson(json.decode(data.body));

          News fromSlider, fromList, favoriteList;

          if (getNewsSliderIndex(id) != -1) {
            fromSlider = _sliderNews[getNewsSliderIndex(id)];
          }

          if (getNewsListIndex(id) != -1) {
            fromList = _listNews[getNewsListIndex(id)];
          }

          if (getNewsFavoriteIndex(id) != -1) {
            favoriteList = _favoriteNews[getNewsFavoriteIndex(id)];
          }

          if (fromSlider != null) {
            fromSlider.likes = returnData.likes;
            fromSlider.dislikes = returnData.dislikes;
            fromSlider.viewers = returnData.viewers;
            fromSlider.uniqueViews = returnData.uniqueViews;
          }

          if (fromList != null) {
            fromList.likes = returnData.likes;
            fromList.dislikes = returnData.dislikes;
            fromList.viewers = returnData.viewers;
            fromList.uniqueViews = returnData.uniqueViews;
          }

          if (favoriteList != null) {
            favoriteList.likes = returnData.likes;
            favoriteList.dislikes = returnData.dislikes;
            favoriteList.viewers = returnData.viewers;
            favoriteList.uniqueViews = returnData.uniqueViews;
          }

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
