import 'package:haber/models/News_Site.dart';

class Constants {
  static const String api_url = "http://192.168.31.93:3000";
  //"http://10.0.3.2:3000";

  static const String sabah_pref = "sabahKey";
  static const String milliyet_pref = "milliyetKey";
  static const String cnnturk_pref = "cnnTurkKey";
  static const String haberturk_pref = "haberTurkKey";
  static const String ntv_pref = "ntvKey";
  static const String init_pref = "initKey";

  static const String favorites_pref = "test_3_favorites";

  static const String auth_token = "authToken";
  static const String uid_token = "uidToken";
  static const String user_token = "userToken";
  static const String password_token = "passToken";
  static const String anonymous_token = "anonymousToken";

  static const String landing_token = "landingPage";

  static const String sabahID = "5f1351a1c961bd0bb0ba82bf";
  static const String milliyetID = "5f1351c3c961bd0bb0ba82c0";
  static const String cnnTurkID = "5f13521fc961bd0bb0ba82c1";
  static const String haberTurkID = "5f13523dc961bd0bb0ba82c2";
  static const String ntvID = "5f1366bf58a4b8083428bee1";

  static const int newsTypeSlider = 1;
  static const int newsTypeList = 2;
  static const int newsTypeFavorites = 3;
  static const int newsTypeLiked = 4;
  static const int newsTypeDisliked = 5;
  static const int newsTypecommented = 6;
  static const int newsTypeSearch = 7;

  static const String searchSortNewToOld = "Yeniden Eskiye"; //0
  static const String searchSortOldToNew = "Eskiden Yeniye"; //1
  static const String searchSortReaderDesc = "En çok okunandan En aza"; //2
  static const String searchSortReaderAsc = "En az okunandan En çoka"; //3
  static const String searchSortCommentDesc = "En çok yorumdan En aza"; //4
  static const String searchSortCommentAsc = "En az yorumdan En çoka"; //55

  static const String searchSlider = "Manşet";
  static const String searchList = "Tüm Haberler";
  static const String searchFavorite = "Favorilerim";
  static const String searchLiked = "Beğendiklerim";
  static const String searchDisliked = "Beğenmediklerim";
  static const String searchCommented = "Yorum yaptıklarım";

  static bool loggedIn = false;
  static bool anonymousLoggedIn = false;

  static List<String> selectedNewsSites = List<String>();

  static const String defaultPhotoUrl =
      "https://firebasestorage.googleapis.com/v0/b/haberapp-54a0c.appspot.com/o/images%2Fdefault_avatar.png?alt=media";

  static List<SiteDetails> newsSites = [
    SiteDetails(
        image: "https://isbh.tmgrup.com.tr/sbh/v5/i/logoBig.png",
        sId: "5f1351a1c961bd0bb0ba82bf",
        name: "Sabah",
        url: "https://www.sabah.com.tr"),
    SiteDetails(
        image:
            "https://i2.milimaj.com/i/milliyet/75/460x340/5bf570e4cb145112d088da10",
        sId: "5f1351c3c961bd0bb0ba82c0",
        name: "Milliyet",
        url: "https://www.milliyet.com.tr"),
    SiteDetails(
        image:
            "https://i2.cnnturk.com/i/cnnturk/75/1200x0/5b9672acae784935dc6edc4d.jpg",
        sId: "5f13521fc961bd0bb0ba82c1",
        name: "CNN Türk",
        url: "https://www.cnnturk.com"),
    SiteDetails(
        image: "https://www.haberturk.com/images/htklogo2.jpg",
        sId: "5f13523dc961bd0bb0ba82c2",
        name: "HABERTÜRK",
        url: "http://www.haberturk.com"),
    SiteDetails(
        image: "https://cdn.ntv.com.tr/img/logo.png",
        sId: "5f1366bf58a4b8083428bee1",
        name: "NTV",
        url: "https://www.ntv.com.tr"),
  ];

  static const int minLengthShort = 3;
  static const int maxLengthShort = 24;

  static const int minLengthMiddle = 3;
  static const int maxLengthMiddle = 40;

  static const int minLengthLong = 3;
  static const int maxLengthLong = 500;
}
