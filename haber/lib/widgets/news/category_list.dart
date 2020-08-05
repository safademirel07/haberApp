import 'package:flutter/material.dart';
import 'package:haber/app_theme.dart';
import 'package:haber/data/constants.dart';
import 'package:haber/data/sharedpref/shared_preference_helper.dart';
import 'package:haber/models/News.dart';
import 'package:haber/providers/news_provider.dart';
import 'package:haber/providers/user_provider.dart';
import 'package:haber/widgets/news/news_list.dart';
import 'package:haber/widgets/news/news_list_element.dart';
import 'package:haber/widgets/others/multi_select_checkbox.dart';
import 'package:provider/provider.dart';

class CategoryList extends StatefulWidget {
  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    _tabController = new TabController(length: 7, vsync: this);
    _tabController.addListener(_handleTabSelection);

    super.initState();
  }

  _handleTabSelection() {
    Provider.of<NewsProvider>(context, listen: false).setLoadingListNews = true;

    Provider.of<UserProvider>(context, listen: false).setLoadingLikedNews =
        true;
    Provider.of<UserProvider>(context, listen: false).setLoadingDislikedNews =
        true;
    Provider.of<UserProvider>(context, listen: false).setLoadingCommentedNews =
        true;
    Provider.of<NewsProvider>(context, listen: false).setLoadingFavoriteNews =
        true;

    Provider.of<NewsProvider>(context, listen: false)
        .setRequiredToFetchAgainFavorites = true;
    Provider.of<NewsProvider>(context, listen: false).clearFavorites();

    Provider.of<NewsProvider>(context, listen: false).clearListNews();
  }

  TabBar _getTabBar() {
    return TabBar(
      labelStyle: AppTheme.body1,
      isScrollable: true,
      unselectedLabelStyle: AppTheme.body1,
      labelColor: Colors.black,
      tabs: <Widget>[
        Tab(
          text: "Anasayfa",
        ),
        Tab(
          text: "Ekonomi",
        ),
        Tab(
          text: "Spor",
        ),
        Tab(
          text: "Otomobil",
        ),
        Tab(
          text: "Teknoloji",
        ),
        Tab(
          text: "Sağlık",
        ),
        Tab(
          text: "Siyaset",
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
                NewsList(
                    ["5f135150c961bd0bb0ba82bb"], Constants.selectedNewsSites),
                NewsList(
                    ["5f13515bc961bd0bb0ba82bc"], Constants.selectedNewsSites),
                NewsList(
                    ["5f135160c961bd0bb0ba82bd"], Constants.selectedNewsSites),
                NewsList(
                    ["5f135169c961bd0bb0ba82be"], Constants.selectedNewsSites),
              ],
            ),
          ),
        )
      ],
    );
  }
}
