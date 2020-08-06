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

  bool get loadingSearchNews => _loadingSearchNews;
  bool get loadingSearchNewsMore => _loadingSearchNewsMore;

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

  Future<void> fetchSearchNews(
      String search, String sort, int type, bool isMore) async {
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
