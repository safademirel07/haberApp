import 'package:flutter/material.dart';
import 'package:haber/data/constants.dart';
import 'package:haber/providers/search_provider.dart';
import 'package:provider/provider.dart';

import '../../app_theme.dart';

class MultiSelectDialogItem<V> {
  const MultiSelectDialogItem(this.value, this.label);

  final V value;
  final String label;
}

class MultiSelectDialog<V> extends StatefulWidget {
  MultiSelectDialog({Key key, this.items, this.initialSelectedValues})
      : super(key: key);

  final List<MultiSelectDialogItem<V>> items;
  final Set<V> initialSelectedValues;

  @override
  State<StatefulWidget> createState() => _MultiSelectDialogState<V>();
}

class _MultiSelectDialogState<V> extends State<MultiSelectDialog<V>> {
  final _selectedValues = Set<V>();
  String valueSort = Constants.searchSortNewToOld;

  final List<String> _itemsSort = [
    Constants.searchSortNewToOld,
    Constants.searchSortOldToNew,
    Constants.searchSortReaderDesc,
    Constants.searchSortReaderAsc,
    Constants.searchSortCommentDesc,
    Constants.searchSortCommentAsc
  ].toList();

  void initState() {
    super.initState();
    if (widget.initialSelectedValues != null) {
      _selectedValues.addAll(widget.initialSelectedValues);
    }
  }

  void _onItemCheckedChange(V itemValue, bool checked) {
    setState(() {
      if (checked) {
        _selectedValues.add(itemValue);
      } else {
        _selectedValues.remove(itemValue);
      }
    });
  }

  void _onCancelTap() {
    Navigator.pop(context);
  }

  void _onSubmitTap() {
    Navigator.pop(context, _selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    final dropdownMenuOptionsSort = _itemsSort
        .map((String item) =>
            new DropdownMenuItem<String>(value: item, child: new Text(item)))
        .toList();

    String sortType =
        Provider.of<SearchProvider>(context, listen: true).getSortType;
    valueSort = sortType;

    return AlertDialog(
      title: Text("Haber Kaynaklarını seç"),
      contentPadding: EdgeInsets.only(top: 12.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTileTheme(
            contentPadding: EdgeInsets.fromLTRB(14.0, 0.0, 24.0, 0.0),
            child: ListBody(
              children: widget.items.map(_buildItem).toList(),
            ),
          ),
          Center(
            child: Container(
              margin: EdgeInsets.only(left: 16),
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
            ),
          )
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('İptal'),
          onPressed: _onCancelTap,
        ),
        FlatButton(
          child: Text('Tamam'),
          onPressed: _onSubmitTap,
        )
      ],
    );
  }

  Widget _buildItem(MultiSelectDialogItem<V> item) {
    final checked = _selectedValues.contains(item.value);
    return CheckboxListTile(
      value: checked,
      title: Text(item.label),
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (checked) => _onItemCheckedChange(item.value, checked),
    );
  }
}
