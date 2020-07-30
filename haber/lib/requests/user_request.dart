import 'package:haber/data/constants.dart';
import 'package:haber/data/sharedpref/shared_preference_helper.dart';
import 'package:http/http.dart' as http;

class UserRequest {
  Future<http.Response> fetchLikedNews(
    int page,
    String search,
  ) async {
    String searchQuery = search.length > 0 ? "&search=$search" : "";
    dynamic token = await SharedPreferenceHelper.getAuthToken;

    return http.get(
      Constants.api_url + "/news/likes?page=$page$searchQuery",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${token.toString()}',
      },
    );
  }

  Future<http.Response> fetchDislikedNews(
    int page,
    String search,
  ) async {
    String searchQuery = search.length > 0 ? "&search=$search" : "";
    dynamic token = await SharedPreferenceHelper.getAuthToken;

    return http.get(
      Constants.api_url + "/news/dislikes?page=$page$searchQuery",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${token.toString()}',
      },
    );
  }

  Future<http.Response> fetchCommentedNews(
    int page,
    String search,
  ) async {
    String searchQuery = search.length > 0 ? "&search=$search" : "";
    dynamic token = await SharedPreferenceHelper.getAuthToken;

    return http.get(
      Constants.api_url + "/news/commented?page=$page$searchQuery",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${token.toString()}',
      },
    );
  }

  Future<http.Response> getUserProfile() async {
    dynamic token = await SharedPreferenceHelper.getAuthToken;

    return http.get(
      Constants.api_url + "/users/me",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${token.toString()}',
      },
    );
  }

  Future<http.Response> changeProfilePhoto(String url) async {
    dynamic token = await SharedPreferenceHelper.getAuthToken;

    return http.post(
      Constants.api_url + "/users/profile_photo?image=$url",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${token.toString()}',
      },
    );
  }
}
