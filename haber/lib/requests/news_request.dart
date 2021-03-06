import 'package:firebase_auth/firebase_auth.dart';
import 'package:haber/data/constants.dart';
import 'package:haber/data/sharedpref/shared_preference_helper.dart';
import 'package:haber/models/Firebase.dart';
import 'package:http/http.dart' as http;

class NewsRequest {
  Future<http.Response> fetchNewsList(int page, String search,
      List<String> categories, List<String> sites, String sort) async {
    String searchQuery = search.length > 0 ? "&search=$search" : "";
    String categoryQuery =
        categories.length > 0 ? ("&categories=" + categories.join(',')) : "";
    String siteQuery =
        sites.length > 0 ? ("&news_sites=" + sites.join(',')) : "";

    String sortQuery = sort.length > 0 ? "&sort=$sort" : "";

    dynamic token = await SharedPreferenceHelper.getAuthToken;

    return http.get(
        Constants.api_url +
            "/news/get?page=$page$searchQuery$categoryQuery$siteQuery$sortQuery",
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          if (token != null && token.length > 0)
            'Authorization': 'Bearer ${token.toString()}',
        });
  }

  Future<http.Response> fetchNewsSlider(int page, List<String> sites) async {
    String siteQuery =
        sites.length > 0 ? ("&news_sites=" + sites.join(',')) : "";
    dynamic token = await SharedPreferenceHelper.getAuthToken;

    return http.get(Constants.api_url + "/news/slider?page=$page$siteQuery",
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          if (token != null && token.length > 0)
            'Authorization': 'Bearer ${token.toString()}',
        });
  }

  Future<http.Response> fetchNewsFavorite(
    int page,
    String search,
  ) async {
    String searchQuery = search.length > 0 ? "&search=$search" : "";
    dynamic token = await SharedPreferenceHelper.getAuthToken;

    return http.get(Constants.api_url + "/news/favorite?page=$page$searchQuery",
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${token.toString()}',
        });
  }

  Future<http.Response> fetchNewsAnonymousFavorite(
      int page, String favorites) async {
    return http.get(
        Constants.api_url +
            "/news/anonymous_favorite?favorites=$favorites&page=$page",
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        });
  }

  Future<http.Response> likeNews(String newsID) async {
    dynamic token = await SharedPreferenceHelper.getAuthToken;

    return http.post(
      Constants.api_url + "/news/like?news=$newsID",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${token.toString()}',
      },
    );
  }

  Future<http.Response> dislikeNews(String newsID) async {
    dynamic token = await SharedPreferenceHelper.getAuthToken;

    return http.post(
      Constants.api_url + "/news/dislike?news=$newsID",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${token.toString()}',
      },
    );
  }

  Future<http.Response> favoriteNews(String newsID) async {
    dynamic token = await SharedPreferenceHelper.getAuthToken;

    return http.post(
      Constants.api_url + "/news/save?news=$newsID",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${token.toString()}',
      },
    );
  }

  Future<http.Response> viewNews(String newsID) async {
    dynamic token = await SharedPreferenceHelper.getAuthToken;

    Firebase firebase = Firebase();
    IdTokenResult tokenResult = await firebase.getUser().getIdToken();
    String authToken = tokenResult.token;
    String uid = firebase.getUser().uid;

    return http.post(
      Constants.api_url +
          "/news/view?news=$newsID&authToken=$authToken&uid=$uid",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${token.toString()}',
      },
    );
  }
}
