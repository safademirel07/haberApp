import 'package:flutter/material.dart';
import 'package:haber/app_theme.dart';
import 'package:haber/models/News.dart';
import 'package:haber/providers/news_provider.dart';
import 'package:haber/widgets/news/news_list_element.dart';
import 'package:provider/provider.dart';

class NewsFavorite extends StatefulWidget {
  String search;

  @override
  _NewsFavoriteState createState() => _NewsFavoriteState();
}

class _NewsFavoriteState extends State<NewsFavorite>
    with SingleTickerProviderStateMixin {
  Future<void> refreshNews() {
    print("burasi 1");
    return Provider.of<NewsProvider>(context, listen: false).fetchFavoriteNews(
      "",
      false,
    );
  }

  Future<void> loadMoreNews() {
    print("burasi 3");
    return Provider.of<NewsProvider>(context, listen: false).fetchFavoriteNews(
      "",
      true,
    );
  }

  @override
  void initState() {
    Future.microtask(() => {
          if (context != null)
            {
              print("burasi 4"),
              Provider.of<NewsProvider>(context, listen: false)
                  .fetchFavoriteNews(
                "",
                false,
              ),
            }
        });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (Provider.of<NewsProvider>(context, listen: false)
        .requiredToFetchAgainFavorites) {
      Future.microtask(() {
        Provider.of<NewsProvider>(context, listen: false)
            .setRequiredToFetchAgainFavorites = false;
        Provider.of<NewsProvider>(context, listen: false)
            .fetchFavoriteNews("", false);
      });
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    List<News> news =
        Provider.of<NewsProvider>(context, listen: true).anyFavoriteNews()
            ? Provider.of<NewsProvider>(context, listen: true).getFavoriteNews()
            : List<News>();

    bool isLoading = Provider.of<NewsProvider>(context, listen: true)
        .loadingFavoriteNewsMore;

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
                Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.search,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          "/search",
                        );
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
          Divider(
            color: Colors.black,
          ),
          news.length > 0
              ? Expanded(
                  child: RefreshIndicator(
                    onRefresh: refreshNews,
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (scrollInfo.metrics.pixels ==
                                scrollInfo.metrics.maxScrollExtent &&
                            !isLoading) {
                          loadMoreNews();
                        }
                      },
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: news.length,
                        itemBuilder: (BuildContext context, int index) {
                          return NewsListElement(news[index], index);
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
