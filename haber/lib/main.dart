import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:haber/data/sharedpref/shared_preference_helper.dart';
import 'package:haber/models/NewsTest.dart';
import 'package:haber/providers/news_provider.dart';
import 'package:haber/widgets/news/news_detail.dart';
import 'package:haber/widgets/news/news_home.dart';
import 'package:haber/widgets/news/news_search.dart';
import 'package:haber/widgets/news/news_slider.dart';
import 'package:haber/widgets/user/login.dart';
import 'package:provider/provider.dart';

import 'app_theme.dart';
import 'data/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SharedPreferenceHelper.getInit.then((value) async {
    print("value ne " + value.toString());
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

  print("ben calistim");
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
  print("newsSites init " + Constants.selectedNewsSites.toString());

  FirebaseAnalytics analytics = FirebaseAnalytics();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => NewsProvider(),
      ),
    ],
    child: MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
        '/home': (context) => NewsHome(),
        '/detail': (context) => NewsDetail(),
        '/login': (context) => Login(),
        '/search': (context) => NewsSearch(),
      },
    ),
  ));
}
