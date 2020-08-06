import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haber/app_theme.dart';
import 'package:haber/data/constants.dart';
import 'package:haber/models/News.dart';
import 'package:haber/providers/search_provider.dart';
import 'package:haber/widgets/news/news_list_element.dart';
import 'package:haber/widgets/news/news_shimmer.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final searchController = TextEditingController();

  void _submitForm() {
    String search = searchController.text;

    Provider.of<SearchProvider>(context, listen: false).clearSearchNews();

    if (search.length >= 3) {
      print("aarama yapiliyor. " + search);
      Provider.of<SearchProvider>(context, listen: false).clearSearchNews();
      Provider.of<SearchProvider>(context, listen: false).setLoadingSearchNews =
          true;
      Provider.of<SearchProvider>(context, listen: false)
          .fetchSearchNews(search, "1", Constants.newsTypeFavorites, false);
    }
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(_submitForm);
  }

  Future<void> refreshNews() {
    print("todo");
  }

  Future<void> loadMoreNews() {
    print("todo");
  }

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

    return Column(
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
              IconButton(
                icon: Icon(
                  Icons.filter_list,
                  color: Colors.black,
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
                              onNotification: (ScrollNotification scrollInfo) {
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
                                itemBuilder: (BuildContext context, int index) {
                                  return NewsListElement(news[index], index,
                                      Constants.newsTypeList);
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
    );
  }
}
