import 'dart:convert';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:haber/data/sharedpref/shared_preference_helper.dart';
import 'package:haber/models/NewsTest.dart';
import 'package:haber/providers/comment_provider.dart';
import 'package:haber/providers/news_provider.dart';
import 'package:haber/providers/search_provider.dart';
import 'package:haber/providers/user_provider.dart';
import 'package:haber/widgets/home.dart';
import 'package:haber/widgets/news/news_detail.dart';
import 'package:haber/widgets/news/news_home.dart';
import 'package:haber/widgets/news/news_search.dart';
import 'package:haber/widgets/news/news_slider.dart';
import 'package:haber/widgets/others/connection.dart';
import 'package:haber/widgets/others/landing.dart';
import 'package:haber/widgets/others/webview.dart';
import 'package:haber/widgets/user/login.dart';
import 'package:haber/widgets/user/profile.dart';
import 'package:haber/widgets/user/register.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_theme.dart';
import 'data/constants.dart';
import 'models/Firebase.dart';

import 'package:http/http.dart' as http;

import 'package:connectivity/connectivity.dart';

import 'package:device_info/device_info.dart';

Future<bool> checkApi() async {
  bool response = false;
  final http.Response responseHttp = await http
      .post(
    Constants.api_url,
  )
      .timeout(Duration(seconds: 3), onTimeout: () {
    return null;
  }).then((value) {
    print("value ne" + value.toString());
    if (value == null) {
      response = false;
    } else {
      response = true;
      print("value.statusCode " + value.statusCode.toString());
    }
  });

  return response;
}

Future<bool> sendLog(AndroidDeviceInfo deviceInfo, PackageInfo packageInfo,
    FirebaseUser user) async {
  bool response = false;

  IdTokenResult tokenResult = await user.getIdToken();
  String authToken = tokenResult.token;

  final http.Response responseLog = await http.post(
    Constants.api_url + "/log/create",
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(
      <String, String>{
        "authToken": authToken,
        "firebaseUID": user.uid,
        "isAnonymous": user.isAnonymous ? "true" : "false",
        "firebaseMail": user.isAnonymous ? "anonymous" : user.email,
        "os": "Android",
        "appVersion": packageInfo.version,
        "appBuildNumber": packageInfo.buildNumber,
        "deviceManufacturer": deviceInfo.manufacturer,
        "deviceModel": deviceInfo.model,
        "deviceProduct": deviceInfo.product,
        "deviceSDK": deviceInfo.version.sdkInt.toString(),
        "deviceID": deviceInfo.id,
        "deviceAndroidID": deviceInfo.androidId,
      },
    ),
  );

  if (responseLog.statusCode == 200) {
    print("Log sent succesfully.");
    response = true;
  } else {
    print("Log couldn't send to server.");
    response = false;
  }

  return response;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);

  var connectivityResult = await (Connectivity().checkConnectivity());

  bool apiResult = await checkApi();
  print("apiresult " + apiResult.toString());

  if (connectivityResult == ConnectivityResult.none) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Connection("İnternet Bağlantısı",
              "İnternet bağlantısı yok, lütfen bağlandıktan sonra tekrar deneyin."),
        ),
      ),
    );
    return;
  }

  if (!apiResult) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Connection("Sunucu Bağlantısı",
              "Sunucuyla bağlantı kurulamadı, lütfen daha sonra tekrar deneyin."),
        ),
      ),
    );
    return;
  }

  await SharedPreferenceHelper.getInit.then((value) async {
    if (!value) {
      // init once
      await SharedPreferenceHelper.setInit(true);
      await SharedPreferenceHelper.setSabah(true);
      await SharedPreferenceHelper.setMilliyet(true);
      await SharedPreferenceHelper.setCNNTurk(true);
      await SharedPreferenceHelper.setHaberTurk(true);
      await SharedPreferenceHelper.setNTV(true);
    }
  });

  final FirebaseAuth _auth = FirebaseAuth.instance;
  var firebase = Firebase();

  await SharedPreferenceHelper.getAuthToken.then((value) async {
    if (value.length == 0) {
      //no value.
      Constants.loggedIn = false;
      AuthResult authResult = await FirebaseAuth.instance.signInAnonymously();
      await SharedPreferenceHelper.setAnonymousID(authResult.user.uid);
      firebase.setUser(authResult.user, true);
      Constants.anonymousLoggedIn = true;
      print("No auth. Anonymous ID " + authResult.user.uid);
      return;
    }
    final http.Response response = await http.post(
      Constants.api_url + "/users/auth",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $value',
      },
    );

    if (response.statusCode == 200) {
      String uid = "";

      await Future.wait([
        SharedPreferenceHelper.getUser,
        SharedPreferenceHelper.getPassword
      ]).then((value) async {
        AuthCredential credential = EmailAuthProvider.getCredential(
            email: value[0].trim(), password: value[1]);

        FirebaseUser firebaseUser =
            (await _auth.signInWithCredential(credential)).user;

        if (firebaseUser.uid == null || firebaseUser.uid.length <= 0) {
          await SharedPreferenceHelper.setAuthToken("");
          await SharedPreferenceHelper.setUID("");
          await SharedPreferenceHelper.setPassword("");
          await SharedPreferenceHelper.setUser("");
          Constants.loggedIn = false;
          AuthResult authResult =
              await FirebaseAuth.instance.signInAnonymously();
          await SharedPreferenceHelper.setAnonymousID(authResult.user.uid);
          firebase.setUser(authResult.user, true);
          Constants.anonymousLoggedIn = true;
          print("No auth. Anonymous ID " + authResult.user.uid);
        } else {
          print("Auth success. Email: " + firebaseUser.email);

          firebase.setUser(firebaseUser);

          uid = firebaseUser.uid;

          Constants.loggedIn = true;
        }
      });
    } else {
      await SharedPreferenceHelper.setAuthToken("");
      await SharedPreferenceHelper.setUID("");
      await SharedPreferenceHelper.setPassword("");
      await SharedPreferenceHelper.setUser("");
      Constants.loggedIn = false;
      AuthResult authResult = await FirebaseAuth.instance.signInAnonymously();
      await SharedPreferenceHelper.setAnonymousID(authResult.user.uid);
      firebase.setUser(authResult.user, true);
      Constants.anonymousLoggedIn = true;
      print("response.statuscode " + response.body);

      print("a No auth. Anonymous ID " + authResult.user.uid);
    }
  });

  Constants.selectedNewsSites.clear();
  await Future.wait([
    SharedPreferenceHelper.getSabah,
    SharedPreferenceHelper.getMilliyet,
    SharedPreferenceHelper.getCNNTurk,
    SharedPreferenceHelper.getHaberTurk,
    SharedPreferenceHelper.getNTV,
  ]).then((value) async {
    if (value[0]) Constants.selectedNewsSites.add(Constants.sabahID);
    if (value[1]) Constants.selectedNewsSites.add(Constants.milliyetID);
    if (value[2]) Constants.selectedNewsSites.add(Constants.cnnTurkID);
    if (value[3]) Constants.selectedNewsSites.add(Constants.haberTurkID);
    if (value[4]) Constants.selectedNewsSites.add(Constants.ntvID);
  });

  FirebaseAnalytics analytics = FirebaseAnalytics();

  bool landing = await SharedPreferenceHelper.getLanding;
  if (landing == false) {
    await SharedPreferenceHelper.setLanding(true);
  }

  if (connectivityResult == ConnectivityResult.wifi ||
      connectivityResult == ConnectivityResult.mobile) {
    //Log start

    DeviceInfoPlugin deviceInfo = await DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      bool result = await sendLog(androidInfo, packageInfo, firebase.getUser());
      print("SendLog" + result.toString());
    } else if (Platform.isIOS) {
      print("ios");
      //todo
    }

    //Log start

    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => NewsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CommentProvider(),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          primaryColor: Colors.black,
          textTheme: AppTheme.textTheme,
          platform: TargetPlatform.android,
        ),
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: analytics),
        ],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('tr', 'TR'),
        ],
        debugShowCheckedModeBanner: false,
        title: 'haberApp',
        initialRoute: landing ? '/landing' : '/landing',
        routes: {
          '/home': (context) => Home(),
          '/news': (context) => NewsHome(),
          '/detail': (context) => NewsDetail(),
          '/login': (context) => Login(),
          '/register': (context) => Register(),
          '/search': (context) => NewsSearch(),
          '/profile': (context) => Profile(),
          '/browser': (context) => Browser(),
          '/landing': (context) => LandingWidget(),
        },
      ),
    ));
  }
}
