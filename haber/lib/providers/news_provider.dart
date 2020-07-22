import 'package:flutter/foundation.dart';
import 'package:haber/data/constants.dart';
import 'dart:convert';

import 'package:haber/models/News.dart';
import 'package:haber/requests/news_request.dart';

class NewsProvider with ChangeNotifier {
  static List<String> _selectedNewsSites = List<String>();

  NewsProvider() {
    print("NewsProvider created");
    _selectedNewsSites = Constants.selectedNewsSites;
  }

  void setSelectedNewsSites() {
    _selectedNewsSites = Constants.selectedNewsSites;
    print("setSelectedNewsSites calisti");
    _requiredToFetchAgain = true;
    notifyListeners();
  }

  List<String> getSelectedNewsSites() {
    return _selectedNewsSites;
  }

  List<News> _sliderNews;
  List<News> _listNews;
  String errorMessage;
  bool loading = true;
  bool adding = false;
  bool loadingMore = false;
  int sliderPage = 1;
  int listPage = 1;

  bool _requiredToFetchAgain = false;

  bool _loadingSliderNews = false, _loadingSliderNewsMore = false;
  bool _loadingListNews = false, _loadingListNewsMore = false;

  bool get loadingSliderNews => _loadingSliderNews;
  bool get loadingSliderNewsMore => _loadingSliderNewsMore;
  bool get loadingListNews => _loadingListNews;
  bool get loadingListNewsMore => _loadingListNewsMore;

  bool get requiredToFetchAgain => _requiredToFetchAgain;

  set setrequiredToFetchAgain(bool value) {
    _requiredToFetchAgain = value;
  }

  set setLoadingSliderNews(bool value) {
    _loadingSliderNews = value;
  }

  set setLoadingSliderNewsMore(bool value) {
    _loadingSliderNewsMore = value;
  }

  set setLoadingListNews(bool value) {
    _loadingListNews = value;
  }

  set setLoadingListNewsMore(bool value) {
    _loadingListNewsMore = value;
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

  Future<void> fetchListNews(String search, List<String> categories,
      List<String> sites, bool isMore) async {
    if (loadingListNews || loadingListNewsMore) return;

    print("fetchListNews" + categories.toString());
    if (isMore)
      setLoadingListNewsMore = true;
    else
      setLoadingListNews = true;

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
            print("burasi??");
            setLoadingListNewsMore = false;
            notifyListeners();
          } else {
            //first page
            setListNews(news);
            setLoadingListNews = false;
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
    print("setlistnews");
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

  // Others

  void setMessage(value) {
    errorMessage = value;
    notifyListeners();
  }

  String getMessage() {
    return errorMessage;
  }
}
