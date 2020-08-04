import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haber/data/constants.dart';
import 'package:haber/models/Firebase.dart';
import 'package:haber/providers/user_provider.dart';
import 'package:haber/widgets/news/news_favorite.dart';
import 'package:haber/widgets/news/news_home.dart';
import 'package:haber/widgets/user/login.dart';
import 'package:provider/provider.dart';

import 'user/profile.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _page = 0;
  PageController _c;
  @override
  void initState() {
    _c = new PageController(
      initialPage: _page,
    );
    super.initState();
  }

  int _currentIndex = 0;

  final List<Widget> _childrenLoggedIn = [
    NewsHome(),
    NewsFavorite(),
    Profile(),
  ];

  final List<Widget> _childrenLoggedOut = [
    NewsHome(),
    NewsFavorite(),
    Login(),
  ];

  void onTabTapped(int index) {
    this._c.animateToPage(index,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);

    setState(() {
      _currentIndex = index;
    });
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit an App'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: new Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: PageView(
          controller: _c,
          onPageChanged: (newPage) {
            setState(() {
              this._page = newPage;
            });
          },
          children: (Constants.loggedIn &&
                  Firebase().getUser() != null &&
                  Constants.anonymousLoggedIn == false)
              ? _childrenLoggedIn
              : _childrenLoggedOut,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _page,
          onTap: (index) {
            this._c.animateToPage(index,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut);
          },
          type: BottomNavigationBarType.fixed,
          items: [
            new BottomNavigationBarItem(
              icon: Icon(Icons.comment),
              title: Text('Haberler'),
            ),
            new BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              title: Text('Favoriler'),
            ),
            new BottomNavigationBarItem(
              icon: Icon(Icons.person),
              title: Text(
                  (Provider.of<UserProvider>(context, listen: true).getUser() !=
                              null &&
                          Constants.anonymousLoggedIn == false)
                      ? 'Profilim'
                      : "Giriş Yap"),
            )
          ],
        ),
      ),
    );
  }
}
