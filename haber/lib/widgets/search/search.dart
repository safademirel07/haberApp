import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haber/app_theme.dart';
import 'package:haber/data/constants.dart';
import 'package:haber/models/News.dart';
import 'package:haber/providers/search_provider.dart';
import 'package:haber/widgets/news/news_list_element.dart';
import 'package:haber/widgets/news/news_shimmer.dart';
import 'package:haber/widgets/others/search_filter.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final searchController = TextEditingController();

  String oldSearch;
  bool force = false;

  void _submitForm() {
    String search = searchController.text;

    print("getSelectedType " + getSelectedType().toString());
    print("getSelectedSort " + getSelectedSort().toString());

    if (search.length < 3)
      Provider.of<SearchProvider>(context, listen: false).clearSearchNews();

    if (oldSearch != search || force == true) {
      print("burasi gelemiyor");
      if (force) force = false;
      oldSearch = search;
      Provider.of<SearchProvider>(context, listen: false).clearSearchNews();

      print("submitform degisti");
      if (search.length >= 3) {
        Provider.of<SearchProvider>(context, listen: false)
            .setLoadingSearchNews = true;
        Provider.of<SearchProvider>(context, listen: false).fetchSearchNews(
            search, getSelectedSort().toString(), getSelectedType(), false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    dropdownValue = Constants.searchList;
    searchController.addListener(_submitForm);
  }

  Future<void> refreshNews() {
    String search = searchController.text;

    print("getSelectedType " + getSelectedType().toString());
    print("getSelectedSort " + getSelectedSort().toString());

    if (search.length < 3)
      Provider.of<SearchProvider>(context, listen: false).clearSearchNews();

    
      print("burasi gelemiyor");
      if (force) force = false;
      oldSearch = search;
      Provider.of<SearchProvider>(context, listen: false).clearSearchNews();

      print("submitform degisti");
      if (search.length >= 3) {
        Provider.of<SearchProvider>(context, listen: false)
            .setLoadingSearchNews = true;
        return Provider.of<SearchProvider>(context, listen: false).fetchSearchNews(
            search, getSelectedSort().toString(), getSelectedType(), false);
      }
    
  }

  Future<void> loadMoreNews() {
    String search = searchController.text;

    print("getSelectedType " + getSelectedType().toString());
    print("getSelectedSort " + getSelectedSort().toString());

    print("submitform degisti");
    if (search.length >= 3) {
      Provider.of<SearchProvider>(context, listen: false).fetchSearchNews(
          search, getSelectedSort().toString(), getSelectedType(), true);
    }
  }

  String dropdownValue;

  int getSelectedType() {
    String type =
        Provider.of<SearchProvider>(context, listen: false).getFilterType;
    int value = 0;
    switch (type) {
      case Constants.searchSlider:
        value = 1;
        break;
      case Constants.searchList:
        value = 2;
        break;
      case Constants.searchFavorite:
        value = 3;
        break;
      case Constants.searchLiked:
        value = 4;
        break;
      case Constants.searchDisliked:
        value = 5;
        break;
      case Constants.searchCommented:
        value = 6;
        break;
      default:
    }
    return value;
  }

  int getSelectedSort() {
    String type =
        Provider.of<SearchProvider>(context, listen: false).getSortType;
    int value = 0;
    switch (type) {
      case Constants.searchSortNewToOld:
        value = 0;
        break;
      case Constants.searchSortOldToNew:
        value = 1;
        break;
      case Constants.searchSortReaderDesc:
        value = 2;
        break;
      case Constants.searchSortReaderAsc:
        value = 3;
        break;
      case Constants.searchSortCommentDesc:
        value = 4;
        break;
      case Constants.searchSortCommentAsc:
        value = 5;
        break;
      default:
    }
    return value;
  }

  final List<String> _items = [
    Constants.searchSlider,
    Constants.searchList,
    Constants.searchFavorite,
    Constants.searchLiked,
    Constants.searchDisliked,
    Constants.searchCommented
  ].toList();

  void _showPopupFilter(BuildContext context) async {
    final returnData = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SearchFilter();
        });

    if (returnData != null) {
      setState(() {
        force = true;
      });
      print("return data " + returnData);
      _submitForm();
    }
    ;
  }

  String _filterType;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);

    List<News> news =
        Provider.of<SearchProvider>(context, listen: true).anySearchNews()
            ? Provider.of<SearchProvider>(context, listen: true).getSearchNews()
            : List<News>();

    bool isLoadingMore = Provider.of<SearchProvider>(context, listen: true)
        .loadingSearchNewsMore;

    bool isLoading =
        Provider.of<SearchProvider>(context, listen: true).loadingSearchNews;

    return Scaffold(
      floatingActionButton: Container(
        height: MediaQuery.of(context).size.width * 0.1,
        width: MediaQuery.of(context).size.width * 0.1,
        child: FloatingActionButton(
            tooltip: "Filtrele",
            child: Icon(Icons.filter_list),
            onPressed: () {
              _showPopupFilter(context);
            }),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 8, top: 8),
                  child: Text(
                    "Arama",
                    style: AppTheme.headline,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: Colors.black,
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                        icon: Icon(Icons.search),
                        border: InputBorder.none,
                        hintText: 'Aramak için bir şeyler yazın.'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: isLoading == true
                  ? MainAxisAlignment.start
                  : news.length == 0
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
              children: <Widget>[
                isLoading == true
                    ? Expanded(
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[300],
                          highlightColor: Colors.grey[100],
                          enabled: true,
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: 5,
                            itemBuilder: (BuildContext context, int index) {
                              return NewsShimmer();
                            },
                          ),
                        ),
                      )
                    : news.length > 0
                        ? Expanded(
                            child: RefreshIndicator(
                              onRefresh: refreshNews,
                              child: NotificationListener<ScrollNotification>(
                                onNotification:
                                    (ScrollNotification scrollInfo) {
                                  if (scrollInfo.metrics.pixels ==
                                          scrollInfo.metrics.maxScrollExtent &&
                                      !isLoading &&
                                      !isLoadingMore) {
                                    loadMoreNews();
                                  }
                                },
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: news.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return NewsListElement(news[index], index,
                                        Constants.newsTypeSearch);
                                  },
                                ),
                              ),
                            ),
                          )
                        : Container(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: Column(
                                children: <Widget>[
                                  if (searchController.text.length >= 3)
                                    Text(
                                      "Bu arama terimini içeren haber bulunamadı.",
                                      style: AppTheme.title,
                                      textAlign: TextAlign.center,
                                    ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "Bir arama terimi girin. En az 3 harf girin.",
                                    style: AppTheme.subtitle,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                if (isLoadingMore)
                  Container(
                      margin: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
