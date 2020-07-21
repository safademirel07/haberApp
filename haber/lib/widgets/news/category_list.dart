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

class CategoryList extends StatefulWidget {
  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    Future.microtask(() => setNewsSites());
    _tabController = new TabController(length: 7, vsync: this);
    super.initState();
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

  List<MultiSelectDialogItem<String>> multiItem = List();

  void populateMultiselect() {
    Constants.newsSites.forEach((newsSite) {
      multiItem.add(MultiSelectDialogItem(newsSite.sId, newsSite.name));
    });
  }

  Set<String> selectedIDs = Set<String>();

  void _showMultiSelect(BuildContext context) async {
    multiItem = [];
    populateMultiselect();
    final items = multiItem;

    selectedIDs.clear();

    await Future.wait([
      SharedPreferenceHelper.getSabah,
      SharedPreferenceHelper.getMilliyet,
      SharedPreferenceHelper.getCNNTurk,
      SharedPreferenceHelper.getHaberTurk,
      SharedPreferenceHelper.getNTV,
    ]).then((value) async {
      if (value[0]) selectedIDs.add(Constants.sabahID);
      if (value[1]) selectedIDs.add(Constants.milliyetID);
      if (value[2]) selectedIDs.add(Constants.cnnTurkID);
      if (value[3]) selectedIDs.add(Constants.haberTurkID);
      if (value[4]) selectedIDs.add(Constants.ntvID);
    });

    final selectedValues = await showDialog<Set<dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          items: items,
          initialSelectedValues: selectedIDs,
        );
      },
    );

    print(selectedValues);
    getvaluefromkey(selectedValues);
  }

  void getvaluefromkey(Set selection) async {
    print("selection ne ");
    print(selection);

    if (selection != null) {
      await SharedPreferenceHelper.setSabah(false);
      await SharedPreferenceHelper.setMilliyet(false);
      await SharedPreferenceHelper.setCNNTurk(false);
      await SharedPreferenceHelper.setHaberTurk(false);
      await SharedPreferenceHelper.setNTV(false);

      for (String x in selection.toList()) {
        Constants.newsSites.forEach((newsSite) async {
          if (newsSite.sId == x) {
            if (newsSite.name == "Sabah") {
              await SharedPreferenceHelper.setSabah(true);
            } else if (newsSite.name == "Milliyet") {
              await SharedPreferenceHelper.setMilliyet(true);
            } else if (newsSite.name == "CNN Türk") {
              print("cnn tamam");
              await SharedPreferenceHelper.setCNNTurk(true);
            } else if (newsSite.name == "HABERTÜRK") {
              await SharedPreferenceHelper.setHaberTurk(true);
            } else if (newsSite.name == "NTV") {
              await SharedPreferenceHelper.setNTV(true);
            }
          }
        });
      }
    }

    await setNewsSites();
  }

  List<String> newsSites = List<String>();

  setNewsSites() async {
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
    Provider.of<NewsProvider>(context, listen: false).setSelectedNewsSites();
    print("newsSites " + Constants.selectedNewsSites.toString());
  }

  @override
  Widget build(BuildContext context) {
    print("Buildde " + Constants.selectedNewsSites.toString());

    return Scaffold(
      body: Column(
        children: <Widget>[
          _getTabBar(),
          Expanded(
            child: Container(
              child: _getTabBarView(
                <Widget>[
                  NewsList(["5f135136c961bd0bb0ba82b8"],
                      Constants.selectedNewsSites),
                  NewsList(["5f13513ec961bd0bb0ba82b9"],
                      Constants.selectedNewsSites),
                  NewsList(["5f135148c961bd0bb0ba82ba"],
                      Constants.selectedNewsSites),
                  NewsList(["5f135150c961bd0bb0ba82bb"],
                      Constants.selectedNewsSites),
                  NewsList(["5f13515bc961bd0bb0ba82bc"],
                      Constants.selectedNewsSites),
                  NewsList(["5f135160c961bd0bb0ba82bd"],
                      Constants.selectedNewsSites),
                  NewsList(["5f135169c961bd0bb0ba82be"],
                      Constants.selectedNewsSites),
                ],
              ),
            ),
          )
        ],
      ),
      floatingActionButton: Container(
        height: MediaQuery.of(context).size.width * 0.1,
        width: MediaQuery.of(context).size.width * 0.1,
        child: FloatingActionButton(
            tooltip: "Filtrele",
            child: Icon(Icons.filter_list),
            onPressed: () {
              _showMultiSelect(context);
            }),
      ),
    );
  }
}
