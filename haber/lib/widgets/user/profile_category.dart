import 'package:flutter/material.dart';
import 'package:haber/app_theme.dart';
import 'package:haber/data/constants.dart';
import 'package:haber/data/sharedpref/shared_preference_helper.dart';
import 'package:haber/models/News.dart';
import 'package:haber/providers/news_provider.dart';
import 'package:haber/widgets/news/news_list.dart';
import 'package:haber/widgets/news/news_list_element.dart';
import 'package:haber/widgets/others/multi_select_checkbox.dart';
import 'package:provider/provider.dart';

class ProfileCategory extends StatefulWidget {
  @override
  _ProfileCategoryState createState() => _ProfileCategoryState();
}

class _ProfileCategoryState extends State<ProfileCategory>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    _tabController = new TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);

    super.initState();
  }

  _handleTabSelection() {
    //   Provider.of<NewsProvider>(context, listen: false).clearListNews();
  }

  TabBar _getTabBar() {
    return TabBar(
      labelStyle: AppTheme.body1,
      isScrollable: true,
      unselectedLabelStyle: AppTheme.body1,
      labelColor: Colors.black,
      tabs: <Widget>[
        Tab(
          text: "Beğenilenler",
        ),
        Tab(
          text: "Beğenilmeyenler",
        ),
        Tab(
          text: "Yorum Yapılanlar",
        ),
      ],
      controller: _tabController,
    );
  }

  TabBarView _getTabBarView(tabs) {
    return TabBarView(
      children: tabs,
      controller: _tabController,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _getTabBar(),
        Expanded(
          child: Container(
            child: _getTabBarView(
              <Widget>[
                NewsList(
                    ["5f135136c961bd0bb0ba82b8"], Constants.selectedNewsSites),
                NewsList(
                    ["5f13513ec961bd0bb0ba82b9"], Constants.selectedNewsSites),
                NewsList(
                    ["5f135148c961bd0bb0ba82ba"], Constants.selectedNewsSites),
              ],
            ),
          ),
        )
      ],
    );
  }
}
