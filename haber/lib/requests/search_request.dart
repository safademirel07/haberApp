import 'package:haber/data/constants.dart';
import 'package:haber/data/sharedpref/shared_preference_helper.dart';
import 'package:http/http.dart' as http;

class SearchRequest {
  Future<http.Response> searchNews(
    int page,
    String search,
    String sort,
    int type,
  ) async {
    String searchQuery = search.length > 0 ? "&search=$search" : "";
    String sortQuery = sort.length > 0 ? "&sort=$sort" : "";
    String typeQuery = "&type=$type";
    dynamic token = await SharedPreferenceHelper.getAuthToken;

    return http.get(
      Constants.api_url +
          "/news/search?page=$page&search=$searchQuery$sortQuery$typeQuery",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${token.toString()}',
      },
    );
  }
}
