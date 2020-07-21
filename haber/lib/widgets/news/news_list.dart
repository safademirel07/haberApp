import 'package:flutter/material.dart';
import 'package:haber/models/News.dart';
import 'package:haber/providers/news_provider.dart';
import 'package:haber/widgets/news/news_list_element.dart';
import 'package:provider/provider.dart';

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
    widget.news_sites = Provider.of<NewsProvider>(context, listen: false)
        .getSelectedNewsSites();
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
      Future.microtask(() => {
            widget.news_sites =
                Provider.of<NewsProvider>(context, listen: false)
                    .getSelectedNewsSites(),
            Provider.of<NewsProvider>(context, listen: false)
                .setRequiredToFetchAgain = false,
            Provider.of<NewsProvider>(context, listen: false)
                .fetchListNews("", widget.categories, widget.news_sites, false)
          });
    }

    print("changed ");
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
    Future.microtask(() => {
          widget.news_sites = Provider.of<NewsProvider>(context, listen: false)
              .getSelectedNewsSites(),
          Provider.of<NewsProvider>(context, listen: false).fetchListNews(
            "",
            widget.categories,
            widget.news_sites,
            false,
          ),
        });
    _tabController = new TabController(length: 2, vsync: this);

    super.initState();
  }

  Widget create(bool isLoading, List<News> news) {
    return Column(
      children: <Widget>[
        Expanded(
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
                  return NewsListElement(news[index]);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    widget.news_sites =
        Provider.of<NewsProvider>(context, listen: true).getSelectedNewsSites();

    print("Buildde " + widget.news_sites.toString());

    List<News> news =
        Provider.of<NewsProvider>(context, listen: true).anyListNews()
            ? Provider.of<NewsProvider>(context, listen: true).getListNews()
            : List<News>();

    bool isLoading =
        Provider.of<NewsProvider>(context, listen: true).loadingListNewsMore;

    print("news " + news.length.toString());
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
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
                    return NewsListElement(news[index]);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
