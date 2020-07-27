import 'package:haber/models/News_Site.dart';

class Constants {
  static const String api_url = "http://10.0.3.2:3000";

  static const String sabah_pref = "sabahKey";
  static const String milliyet_pref = "milliyetKey";
  static const String cnnturk_pref = "cnnTurkKey";
  static const String haberturk_pref = "haberTurkKey";
  static const String ntv_pref = "ntvKey";
  static const String init_pref = "initKey";

  static const String auth_token = "authToken";
  static const String uid_token = "uidToken";
  static const String user_token = "userToken";
  static const String password_token = "passToken";

  static const String sabahID = "5f1351a1c961bd0bb0ba82bf";
  static const String milliyetID = "5f1351c3c961bd0bb0ba82c0";
  static const String cnnTurkID = "5f13521fc961bd0bb0ba82c1";
  static const String haberTurkID = "5f13523dc961bd0bb0ba82c2";
  static const String ntvID = "5f1366bf58a4b8083428bee1";

  static bool loggedIn = false;

  static List<String> selectedNewsSites = List<String>();

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
