import 'dart:convert';

import 'package:haber/data/constants.dart';
import 'package:haber/data/sharedpref/shared_preference_helper.dart';
import 'package:http/http.dart' as http;

class CommentRequest {
  Future<http.Response> getComment(int page, String newsID) async {
    dynamic token = await SharedPreferenceHelper.getAuthToken;

    return http.get(
      Constants.api_url + "/comment/get?page=$page&news=$newsID",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${token.toString()}',
      },
    );
  }

  Future<http.Response> addComment(String newsID, String comment) async {
    dynamic token = await SharedPreferenceHelper.getAuthToken;

    return http.post(
      Constants.api_url + "/comment/add",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${token.toString()}',
      },
      body: jsonEncode(
        <String, String>{
          'news': newsID,
          'comment': comment,
        },
      ),
    );
  }
}
