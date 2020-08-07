import 'package:flutter/material.dart';
import 'package:haber/app_theme.dart';
import 'package:haber/data/constants.dart';
import 'package:haber/providers/search_provider.dart';
import 'package:provider/provider.dart';

class SearchFilter extends StatefulWidget {
  SearchFilter({Key key}) : super(key: key);

  @override
  _SearchFilterState createState() => _SearchFilterState();
}

class _SearchFilterState extends State<SearchFilter> {
  String valueSearch = Constants.searchList;
  String valueSort = Constants.searchSortNewToOld;

  final List<String> _itemsType = [
    Constants.searchSlider,
    Constants.searchList,
    Constants.searchFavorite,
    Constants.searchLiked,
    Constants.searchDisliked,
    Constants.searchCommented
  ].toList();

  final List<String> _itemsSort = [
    Constants.searchSortNewToOld,
    Constants.searchSortOldToNew,
    Constants.searchSortReaderDesc,
    Constants.searchSortReaderAsc,
    Constants.searchSortCommentDesc,
    Constants.searchSortCommentAsc
  ].toList();

  @override
  void initState() {
    valueSearch =
        Provider.of<SearchProvider>(context, listen: false).getFilterType;

    super.initState();
  }

  void _onSubmitTap() {
    Navigator.pop(
      context,
      valueSearch,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dropdownMenuOptionsType = _itemsType
        .map((String item) =>
            new DropdownMenuItem<String>(value: item, child: new Text(item)))
        .toList();

    final dropdownMenuOptionsSort = _itemsSort
        .map((String item) =>
            new DropdownMenuItem<String>(value: item, child: new Text(item)))
        .toList();

    String filterType =
        Provider.of<SearchProvider>(context, listen: true).getFilterType;
    String sortType =
        Provider.of<SearchProvider>(context, listen: true).getSortType;

    valueSearch = filterType;
    valueSort = sortType;

    return AlertDialog(
      title: Text("Nerede aramak istiyorsun?"),
      contentPadding: EdgeInsets.only(top: 12.0, left: 16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Kaynak:",
                  style: AppTheme.caption,
                ),
                SizedBox(
                  width: 20,
                ),
                DropdownButton<String>(
                  hint: Text("safa"),
                  iconSize: 24,
                  elevation: 16,
                  style: AppTheme.caption,
                  underline: Container(
                    height: 2,
                    color: Colors.black,
                  ),
                  onChanged: (s) {
                    Provider.of<SearchProvider>(context, listen: false)
                        .setFilterType = s;
                    setState(() {
                      valueSearch = s;
                    });
                  },
                  value: valueSearch,
                  items: dropdownMenuOptionsType,
                ),
              ],
            ),
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Sıralama:",
                  style: AppTheme.caption,
                ),
                SizedBox(
                  width: 10,
                ),
                DropdownButton<String>(
                  iconSize: 24,
                  elevation: 16,
                  style: AppTheme.caption,
                  underline: Container(
                    height: 2,
                    color: Colors.black,
                  ),
                  onChanged: (s) {
                    Provider.of<SearchProvider>(context, listen: false)
                        .setSortType = s;
                    setState(() {
                      valueSort = s;
                    });
                  },
                  value: valueSort,
                  items: dropdownMenuOptionsSort,
                ),
              ],
            ),
          )
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Tamam'),
          onPressed: _onSubmitTap,
        )
      ],
    );
  }
}
