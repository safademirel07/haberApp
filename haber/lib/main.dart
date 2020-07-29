import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:haber/data/sharedpref/shared_preference_helper.dart';
import 'package:haber/models/NewsTest.dart';
import 'package:haber/providers/news_provider.dart';
import 'package:haber/providers/user_provider.dart';
import 'package:haber/widgets/home.dart';
import 'package:haber/widgets/news/news_detail.dart';
import 'package:haber/widgets/news/news_home.dart';
import 'package:haber/widgets/news/news_search.dart';
import 'package:haber/widgets/news/news_slider.dart';
import 'package:haber/widgets/others/webview.dart';
import 'package:haber/widgets/user/login.dart';
import 'package:haber/widgets/user/profile.dart';
import 'package:haber/widgets/user/register.dart';
import 'package:provider/provider.dart';

import 'app_theme.dart';
import 'data/constants.dart';
import 'models/Firebase.dart';

import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);

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

  await SharedPreferenceHelper.getAuthToken.then((value) async {
    if (value.length == 0) {
      //no value.
      Constants.loggedIn = false;
      print("No auth.");
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
        var firebase = Firebase();

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

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => NewsProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => UserProvider(),
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
      debugShowCheckedModeBanner: false,
      title: 'haberApp',
      initialRoute: '/home',
      routes: {
        '/home': (context) => Home(),
        '/news': (context) => NewsHome(),
        '/detail': (context) => NewsDetail(),
        '/login': (context) => Login(),
        '/register': (context) => Register(),
        '/search': (context) => NewsSearch(),
        '/profile': (context) => Profile(),
        '/browser': (context) => Browser(),
      },
    ),
  ));
}
