import 'package:flutter/material.dart';
import 'package:haber/app_theme.dart';
import 'package:haber/data/constants.dart';
import 'package:haber/models/News.dart';
import 'package:haber/providers/news_provider.dart';
import 'package:haber/providers/user_provider.dart';
import 'package:haber/widgets/news/news_list_element.dart';
import 'package:haber/widgets/news/news_shimmer.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class NewsList extends StatefulWidget {
  List<String> categories = List<String>();
  List<String> news_sites = List<String>();

  NewsList(this.categories, this.news_sites);

  @override
  _NewsListState createState() => _NewsListState();
}

class _NewsListState extends State<NewsList>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  Future<void> refreshNews() {
    print("refresh");
    widget.news_sites = Provider.of<NewsProvider>(context, listen: false)
        .getSelectedNewsSites();

    Provider.of<NewsProvider>(context, listen: false).fetchSliderNews(
      widget.news_sites,
      false,
    );

    Provider.of<NewsProvider>(context, listen: false).fetchListNews(
      "",
      widget.categories,
      widget.news_sites,
      false,
    );

    return Provider.of<NewsProvider>(context, listen: false).fetchListNews(
      "",
      widget.categories,
      widget.news_sites,
      false,
    );
  }

  @override
  void didChangeDependencies() {
    if (Provider.of<NewsProvider>(context, listen: false)
        .requiredToFetchAgain) {
      Future.microtask(() {
        widget.news_sites = Provider.of<NewsProvider>(context, listen: false)
            .getSelectedNewsSites();
        Provider.of<NewsProvider>(context, listen: false)
            .setrequiredToFetchAgain = false;
        Provider.of<NewsProvider>(context, listen: false)
            .fetchListNews("", widget.categories, widget.news_sites, false);
      });
    }

    super.didChangeDependencies();
  }

  Future<void> loadMoreNews() {
    widget.news_sites = Provider.of<NewsProvider>(context, listen: false)
        .getSelectedNewsSites();

    return Provider.of<NewsProvider>(context, listen: false).fetchListNews(
      "",
      widget.categories,
      widget.news_sites,
      true,
    );
  }

  @override
  void initState() {
    Future.microtask(() {
      if (context != null) {
        widget.news_sites = Provider.of<NewsProvider>(context, listen: false)
            .getSelectedNewsSites();
        Provider.of<NewsProvider>(context, listen: false).fetchListNews(
          "",
          widget.categories,
          widget.news_sites,
          false,
        );

        Provider.of<UserProvider>(context, listen: false).setLoadingLikedNews =
            true;
        Provider.of<UserProvider>(context, listen: false)
            .setLoadingDislikedNews = true;
        Provider.of<UserProvider>(context, listen: false)
            .setLoadingCommentedNews = true;
        Provider.of<NewsProvider>(context, listen: false)
            .setLoadingFavoriteNews = true;
        Provider.of<NewsProvider>(context, listen: false).setLoadingListNews =
            true;
      }
    });

    _tabController = new TabController(length: 2, vsync: this);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    widget.news_sites =
        Provider.of<NewsProvider>(context, listen: true).getSelectedNewsSites();

    List<News> news =
        Provider.of<NewsProvider>(context, listen: true).anyListNews()
            ? Provider.of<NewsProvider>(context, listen: true).getListNews()
            : List<News>();

    bool isLoadingMore =
        Provider.of<NewsProvider>(context, listen: true).loadingListNewsMore;

    bool isLoading =
        Provider.of<NewsProvider>(context, listen: true).loadingListNews;

    return Scaffold(
      body: Column(
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
                                !isLoading &&
                                !isLoadingMore) {
                              loadMoreNews();
                            }
                          },
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: news.length,
                            itemBuilder: (BuildContext context, int index) {
                              return NewsListElement(
                                  news[index], index, Constants.newsTypeList);
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
                            Text(
                              "Bu kategoride girilmiş haber bulunamadı.",
                              style: AppTheme.title,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Haber kaynaklarını değiştirmeyi deneyin.",
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
    );
  }
}
