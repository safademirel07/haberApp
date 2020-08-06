import 'package:flutter/material.dart';
import 'package:haber/app_theme.dart';
import 'package:haber/data/constants.dart';
import 'package:haber/data/sharedpref/shared_preference_helper.dart';
import 'package:haber/models/News.dart';
import 'package:haber/providers/news_provider.dart';
import 'package:haber/widgets/news/news_list_element.dart';
import 'package:haber/widgets/news/news_shimmer.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class NewsFavorite extends StatefulWidget {
  String search;

  @override
  _NewsFavoriteState createState() => _NewsFavoriteState();
}

class _NewsFavoriteState extends State<NewsFavorite>
    with SingleTickerProviderStateMixin {
  Future<void> refreshNews() async {
    if (Constants.anonymousLoggedIn == true) {
      String favorites = await SharedPreferenceHelper.getFavorites;
      return Provider.of<NewsProvider>(context, listen: false)
          .fetchAnonymousFavoriteNews(
        favorites,
        false,
      );
    } else
      return Provider.of<NewsProvider>(context, listen: false)
          .fetchFavoriteNews(
        "",
        false,
      );
  }

  Future<void> loadMoreNews() async {
    if (Constants.anonymousLoggedIn == true) {
      String favorites = await SharedPreferenceHelper.getFavorites;
      return Provider.of<NewsProvider>(context, listen: false)
          .fetchAnonymousFavoriteNews(
        favorites,
        false,
      );
    } else
      return Provider.of<NewsProvider>(context, listen: false)
          .fetchFavoriteNews(
        "",
        true,
      );
  }

  @override
  void initState() {
    Future.microtask(() {
      if (context != null) {
        Provider.of<NewsProvider>(context, listen: false)
            .setLoadingFavoriteNews = true;
        if (Constants.anonymousLoggedIn == true) {
          // initstate cant be async
          WidgetsBinding.instance.addPostFrameCallback((_) {
            refreshNews();
          });
        } else {
          Provider.of<NewsProvider>(context, listen: false).clearFavorites();
          Provider.of<NewsProvider>(context, listen: false).fetchFavoriteNews(
            "",
            false,
          );
        }
      }
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (Provider.of<NewsProvider>(context, listen: true)
        .requiredToFetchAgainFavorites) {
      print("required to fetch???");
      Future.microtask(() {
        Provider.of<NewsProvider>(context, listen: false)
            .setLoadingFavoriteNews = true;
        Provider.of<NewsProvider>(context, listen: false)
            .setRequiredToFetchAgainFavorites = false;

        if (Constants.anonymousLoggedIn == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            refreshNews();
          });
        } else {
          Provider.of<NewsProvider>(context, listen: false)
              .fetchFavoriteNews("", false);
        }
      });
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    List<News> news;

    bool isAnonymous =
        Provider.of<NewsProvider>(context, listen: true).isAnonymous;

    news = Provider.of<NewsProvider>(context, listen: true).anyFavoriteNews()
        ? Provider.of<NewsProvider>(context, listen: true).getFavoriteNews()
        : List<News>();

    bool isLoadingMore = Provider.of<NewsProvider>(context, listen: true)
        .loadingFavoriteNewsMore;
    bool isLoading =
        Provider.of<NewsProvider>(context, listen: true).loadingFavoriteNews;

    print("isLoading build " + isLoading.toString());

    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 8, top: 8),
                  child: Text(
                    "Favorilerin",
                    style: AppTheme.headline,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: Colors.black,
          ),
          (isLoading == true)
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
                        // return NewsListElement(news, 0, 0, true);
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
                                !isLoadingMore &&
                                !isLoading) {
                              loadMoreNews();
                            }
                          },
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: news.length,
                            itemBuilder: (BuildContext context, int index) {
                              return NewsListElement(news[index], index,
                                  Constants.newsTypeFavorites);
                            },
                          ),
                        ),
                      ),
                    )
                  : Expanded(
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Daha önce hiç bir haberi Favori'ye eklememişsin.",
                                style: AppTheme.title,
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Haberlerin sonunda Favori'ye Ekle ile haberleri Favori'ye alabilirsin.",
                                style: AppTheme.subtitle,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
        ],
      ),
    );
  }
}
