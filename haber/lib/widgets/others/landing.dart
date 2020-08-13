import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:haber/data/constants.dart';
import 'package:haber/models/Landing.dart';
import 'package:sk_onboarding_screen/flutter_onboarding.dart';
import 'package:sk_onboarding_screen/sk_onboarding_screen.dart';

import '../../app_theme.dart';
import 'package:http/http.dart' as http;

class LandingWidget extends StatefulWidget {
  @override
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<LandingWidget> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _globalKey = new GlobalKey<ScaffoldState>();

  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchLandingPage();
  }

  fetchLandingPage() async {
    http.Response response = await http.get(
      Constants.api_url + "/landing/get",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      pages.clear();

      List<Landing> landing = (json.decode(response.body) as List)
          .map((data) => Landing.fromJson(data))
          .toList();

      setState(() {
        landing.forEach((element) {
          print("pages add" + element.title);
          pages.add(
            new SkOnboardingModel(
                title: element.title,
                description: element.description,
                titleColor: Color(int.parse(element.titleColor)),
                descripColor: Color(int.parse(element.descripColor)),
                imagePath: element.imagePath),
          );
        });
        loading = true;
      });
    } else {
      print("Show default landing");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      body: loading
          ? SKOnboardingScreen(
              bgColor: Colors.white,
              themeColor: AppTheme.nearlyBlack,
              pages: pages,
              skipClicked: (value) {
                Navigator.pushReplacementNamed(
                  context,
                  "/home",
                );
              },
              getStartedClicked: (value) {
                Navigator.pushReplacementNamed(
                  context,
                  "/home",
                );
              },
            )
          : Center(
              child: Theme(
                data: Theme.of(context).copyWith(accentColor: Colors.black),
                child: new CircularProgressIndicator(),
              ),
            ),
    );
  }

  List<SkOnboardingModel> pages = [
    SkOnboardingModel(
        title: 'En Son Haberler',
        description: 'Senin seçtiğinden sitelerden en son haberleri öğren.',
        titleColor: Colors.black,
        descripColor: const Color(0xFF929794),
        imagePath: 'assets/images/vector_2.png'),
    SkOnboardingModel(
        title: 'Fikrini Belirt',
        description: 'Haberlere yorum yaparak fikrini belirt.',
        titleColor: Colors.black,
        descripColor: const Color(0xFF929794),
        imagePath: 'assets/images/vector_5.png'),
    SkOnboardingModel(
        title: 'Üyelik',
        description: 'Üye olarak haberlere yorum yap, beğen, favorine ekle!',
        titleColor: Colors.black,
        descripColor: const Color(0xFF929794),
        imagePath: 'assets/images/vector_4.png'),
  ];
}
