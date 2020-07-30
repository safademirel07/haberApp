import 'package:flutter/material.dart';
import 'package:haber/app_theme.dart';
import 'package:haber/data/constants.dart';
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
    Future.microtask(() => {
          if (context != null)
            {
              widget.news_sites =
                  Provider.of<NewsProvider>(context, listen: false)
                      .getSelectedNewsSites(),
              Provider.of<NewsProvider>(context, listen: false).fetchListNews(
                "",
                widget.categories,
                widget.news_sites,
                false,
              ),
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

    bool isLoading =
        Provider.of<NewsProvider>(context, listen: true).loadingListNewsMore;

    return Scaffold(
      body: Column(
        mainAxisAlignment: news.length == 0
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: <Widget>[
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
        ],
      ),
    );
  }
}
