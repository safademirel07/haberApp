import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:haber/data/constants.dart';
import 'dart:convert';

import 'package:haber/models/News.dart';
import 'package:haber/requests/search_request.dart';
import 'package:provider/provider.dart';

class SearchProvider with ChangeNotifier {
  static List<News> _searchNews = List<News>();
  String errorMessage;

  bool _loadingSearchNews = false, _loadingSearchNewsMore = false;

  String _filterType = Constants.searchList;
  String _sortType = Constants.searchSortNewToOld;

  bool get loadingSearchNews => _loadingSearchNews;
  bool get loadingSearchNewsMore => _loadingSearchNewsMore;

  String get getFilterType => _filterType;

  set setFilterType(String type) {
    _filterType = type;
    notifyListeners();
  }

  String get getSortType => _sortType;

  set setSortType(String type) {
    _sortType = type;
    notifyListeners();
  }

  void clearSearchNews() {
    _searchNews = List<News>();
    notifyListeners();
  }

  int searchPage = 1;

  set setLoadingSearchNews(bool value) {
    _loadingSearchNews = value;
    notifyListeners();
  }

  set setLoadingSearchNewsMore(bool value) {
    _loadingSearchNewsMore = value;
    notifyListeners();
  }

  int getNewsSearchListIndex(String id) {
    return _searchNews == null
        ? -1
        : _searchNews.indexWhere((news) => news.sId == id);
  }

  int getSelectedSort() {
    int value = 0;
    switch (getSortType) {
      case Constants.searchSortNewToOld:
        value = 0;
        break;
      case Constants.searchSortOldToNew:
        value = 1;
        break;
      case Constants.searchSortReaderDesc:
        value = 2;
        break;
      case Constants.searchSortReaderAsc:
        value = 3;
        break;
      case Constants.searchSortCommentDesc:
        value = 4;
        break;
      case Constants.searchSortCommentAsc:
        value = 5;
        break;
      default:
    }
    return value;
  }

  void updateAllLists(String id, News returnNews) {
    News fromSearch;

    if (getNewsSearchListIndex(id) != -1) {
      fromSearch = _searchNews[getNewsSearchListIndex(id)];
    }

    if (fromSearch != null) {
      print("uniqueViews " + returnNews.uniqueViews.toString());

      fromSearch.likes = returnNews.likes;
      fromSearch.dislikes = returnNews.dislikes;
      fromSearch.viewers = returnNews.viewers;
      fromSearch.isLiked = returnNews.isLiked;
      fromSearch.isDisliked = returnNews.isDisliked;
      fromSearch.uniqueViews = returnNews.uniqueViews;
      fromSearch.isFavorited = returnNews.isFavorited;
    }

    notifyListeners();
  }

  Future<void> fetchSearchNews(
      String search, String sort, int type, bool isMore) async {
    if (loadingSearchNewsMore) return;

    if (isMore)
      setLoadingSearchNewsMore = true;
    else
      setLoadingSearchNews = true;

    try {
      if (!isMore) searchPage = 1;
      SearchRequest()
          .searchNews(
              (isMore ? (searchPage + 1) : searchPage), search, sort, type)
          .then((data) {
        if (data.statusCode == 200) {
          List<News> news = (json.decode(data.body) as List)
              .map((data) => News.fromJson(data))
              .toList();

          print("search page ne" + searchPage.toString());

          if (isMore) {
            if (news.length > 0) {
              ++searchPage;
            }
            _searchNews.addAll(news);
            setLoadingSearchNewsMore = false;
            notifyListeners();
          } else {
            //first page
            setSearchNews(news);
            setLoadingSearchNews = false;
            notifyListeners();
          }
        } else {
          Map<String, dynamic> result = json.decode(data.body);
          setMessage(result["error"]);
          setLoadingSearchNews = false;
          setLoadingSearchNewsMore = false;
        }
      });
    } catch (e) {
      setLoadingSearchNews = false;
      setLoadingSearchNewsMore = false;
    }
  }

  void setSearchNews(value) {
    _searchNews = value;
    notifyListeners();
  }

  List<News> getSearchNews() {
    return _searchNews;
  }

  bool anySearchNews() {
    return _searchNews != null ? _searchNews.length == 0 ? false : true : false;
  }

  int searchNewsLength() {
    return _searchNews != null ? _searchNews.length : 0;
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
