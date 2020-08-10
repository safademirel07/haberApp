import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:haber/app_theme.dart';
import 'package:haber/data/constants.dart';
import 'package:haber/data/sharedpref/shared_preference_helper.dart';
import 'package:haber/models/NewsTest.dart';
import 'package:haber/providers/news_provider.dart';
import 'package:haber/widgets/news/category_list.dart';
import 'package:haber/widgets/news/news_detail.dart';
import 'package:haber/widgets/news/news_list.dart';
import 'package:haber/widgets/news/news_list_element.dart';
import 'package:haber/widgets/news/news_slider.dart';
import 'package:haber/widgets/others/multi_select_checkbox.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'dart:async';


class NewsHome extends StatefulWidget {
  @override
  _NewsHomeState createState() => _NewsHomeState();
}

class _NewsHomeState extends State<NewsHome> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  Future<void> refreshNews() {}

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);

    return Scaffold(
      key: _scaffoldKey,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverPersistentHeader(
              pinned: false,
              floating: false,
              delegate: NewsSlider(
                minExtent: MediaQuery.of(context).size.height * 0.39,
                maxExtent: MediaQuery.of(context).size.height * 0.39,
              ),
            ),
          ];
        },
        body: CategoryList(),
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
  }
}
