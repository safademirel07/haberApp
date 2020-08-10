import 'package:flutter/material.dart';
import 'package:sk_onboarding_screen/flutter_onboarding.dart';
import 'package:sk_onboarding_screen/sk_onboarding_screen.dart';

import '../../app_theme.dart';

class Landing extends StatefulWidget {
  @override
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _globalKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      body: SKOnboardingScreen(
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
      ),
    );
  }

  final pages = [
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
