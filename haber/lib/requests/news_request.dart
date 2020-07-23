import 'package:haber/data/constants.dart';
import 'package:http/http.dart' as http;

class NewsRequest {
  Future<http.Response> fetchNewsList(int page, String search,
      List<String> categories, List<String> sites) async {
    String searchQuery = search.length > 0 ? "&search=$search" : "";
    String categoryQuery =
        categories.length > 0 ? ("&categories=" + categories.join(',')) : "";
    String siteQuery =
        sites.length > 0 ? ("&news_sites=" + sites.join(',')) : "";

    return http.get(
        Constants.api_url +
            "/news/get?page=$page$searchQuery$categoryQuery$siteQuery",
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        });
  }

  Future<http.Response> fetchNewsSlider(int page, List<String> sites) async {
    String siteQuery =
        sites.length > 0 ? ("&news_sites=" + sites.join(',')) : "";


    return http.get(Constants.api_url + "/news/slider?page=$page$siteQuery",
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        });
  }
}
