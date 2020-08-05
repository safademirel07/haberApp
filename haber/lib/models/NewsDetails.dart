import 'package:flutter/material.dart';

class NewsDetails {
  int _index;
  bool _isSlider;
  int _type;
  List<String> _listType;

  bool isSlider() {
    return _isSlider;
  }

  int getType() {
    return _type;
  }

  List<String> getListType() {
    return _listType;
  }

  int getIndex() {
    return _index;
  }

  NewsDetails(int index, bool isSlider, int type, [List<String> listType]) {
    _index = index;
    _isSlider = isSlider;
    _type = type;
    _listType = listType;
    print("listtype yaptim " + _listType.toString());
  }

  //type == 1 > Slider
  //type == 2 > List
  //type == 3 > Favorites
  //type == 4 > Liked
  //type == 5 > Disliked
  //type == 6 > Commented
}
