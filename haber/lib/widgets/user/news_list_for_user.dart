import 'package:flutter/material.dart';
import 'package:haber/app_theme.dart';
import 'package:haber/models/News.dart';
import 'package:haber/providers/news_provider.dart';
import 'package:haber/providers/user_provider.dart';
import 'package:haber/widgets/news/news_list_element.dart';
import 'package:provider/provider.dart';

class NewsListForUser extends StatefulWidget {
  int newsType; // 1 liked, 2 disliked, 3 commented

  NewsListForUser(this.newsType);

  @override
  _NewsListForUserState createState() => _NewsListForUserState();
}

class _NewsListForUserState extends State<NewsListForUser>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  Future<void> refreshNews() {
    if (widget.newsType == 1) {
      return Provider.of<UserProvider>(context, listen: false).fetchLikedNews(
        "",
        false,
      );
    } else if (widget.newsType == 2) {
      return Provider.of<UserProvider>(context, listen: false)
          .fetchDislikedNews(
        "",
        false,
      );
    } else if (widget.newsType == 3) {
      return Provider.of<UserProvider>(context, listen: false)
          .fetchCommentedNews(
        "",
        false,
      );
    }
  }

  @override
  void didChangeDependencies() {
    print("changed dependencies news for users");
    super.didChangeDependencies();
  }

  Future<void> loadMoreNews() {
    if (widget.newsType == 1) {
      return Provider.of<UserProvider>(context, listen: false).fetchLikedNews(
        "",
        true,
      );
    } else if (widget.newsType == 2) {
      return Provider.of<UserProvider>(context, listen: false)
          .fetchDislikedNews(
        "",
        true,
      );
    } else if (widget.newsType == 3) {
      return Provider.of<UserProvider>(context, listen: false)
          .fetchCommentedNews(
        "",
        true,
      );
    }
  }

  @override
  void initState() {
    Future.microtask(() {
      if (context != null) {
        if (widget.newsType == 1) {
          return Provider.of<UserProvider>(context, listen: false)
              .fetchLikedNews(
            "",
            false,
          );
        } else if (widget.newsType == 2) {
          return Provider.of<UserProvider>(context, listen: false)
              .fetchDislikedNews(
            "",
            false,
          );
        } else if (widget.newsType == 3) {
          return Provider.of<UserProvider>(context, listen: false)
              .fetchCommentedNews(
            "",
            false,
          );
        }
      }
    });
    _tabController = new TabController(length: 2, vsync: this);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<News> news = List<News>();

    if (widget.newsType == 1) {
      news = Provider.of<UserProvider>(context, listen: true).anyLikedNews()
          ? Provider.of<UserProvider>(context, listen: false).getLikedNews()
          : List<News>();
    } else if (widget.newsType == 2) {
      news = Provider.of<UserProvider>(context, listen: true).anyDislikedNews()
          ? Provider.of<UserProvider>(context, listen: false).getDislikedNews()
          : List<News>();
      ;
    } else if (widget.newsType == 3) {
      news = Provider.of<UserProvider>(context, listen: true).anyCommentedNews()
          ? Provider.of<UserProvider>(context, listen: false).getCommentedNews()
          : List<News>();
      ;
    }

    bool isLoading = true;
    if (widget.newsType == 1) {
      isLoading =
          Provider.of<UserProvider>(context, listen: true).loadingLikedNews;
    } else if (widget.newsType == 2) {
      isLoading =
          Provider.of<UserProvider>(context, listen: true).loadingDislikedNews;
    } else if (widget.newsType == 3) {
      isLoading =
          Provider.of<UserProvider>(context, listen: true).loadingCommentedNews;
    }

    String errorMessage = "";

    if (widget.newsType == 1) {
      errorMessage = "Beğendiniz bir haber yok.";
    } else if (widget.newsType == 2) {
      errorMessage = "Beğenmediğiniz bir haber yok.";
    } else if (widget.newsType == 3) {
      errorMessage = "Yorum yaptığınız bir haber yok.";
    }

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
                              news[index], index, widget.newsType + 3);
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
                          errorMessage,
                          style: AppTheme.title,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 10,
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
