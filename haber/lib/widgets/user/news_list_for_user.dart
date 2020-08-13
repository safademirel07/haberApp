import 'package:flutter/material.dart';
import 'package:haber/app_theme.dart';
import 'package:haber/models/News.dart';
import 'package:haber/providers/news_provider.dart';
import 'package:haber/providers/user_provider.dart';
import 'package:haber/widgets/news/news_list_element.dart';
import 'package:haber/widgets/news/news_shimmer.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

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
      print("refresh?_");
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
          print("fetch commented");
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
    bool isLoadingMore = false;
    if (widget.newsType == 1) {
      isLoading =
          Provider.of<UserProvider>(context, listen: true).loadingLikedNews;
      isLoadingMore =
          Provider.of<UserProvider>(context, listen: true).loadingLikedNewsMore;
    } else if (widget.newsType == 2) {
      isLoading =
          Provider.of<UserProvider>(context, listen: true).loadingDislikedNews;
      isLoadingMore = Provider.of<UserProvider>(context, listen: true)
          .loadingDislikedNewsMore;
    } else if (widget.newsType == 3) {
      isLoading =
          Provider.of<UserProvider>(context, listen: true).loadingCommentedNews;
      isLoadingMore = Provider.of<UserProvider>(context, listen: true)
          .loadingCommentedNewsMore;
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
        mainAxisAlignment: MainAxisAlignment.start,
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
                                !isLoadingMore &&
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
                        child: Expanded(
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
                    ),
        ],
      ),
    );
  }
}

/*
                        News news = News(
                          sId: "",
                          viewers: 0,
                          title: "Yükleniyor.",
                          description: "",
                          body: "",
                          date: "Lorem IpsumLorem IpsumLorem IpsumLorem Ipsum",
                          link: "",
                          isLiked: false,
                          isDisliked: false,
                          isFavorited: false,
                          rssDetails: null,
                          siteDetails: null,
                          categoryDetails: null,
                          likes: 0,
                          dislikes: 0,
                          image:
                              "https://cdn1.ntv.com.tr/gorsel/mhf0vJHJFUGtpyJY99o14A.jpg?width=1200&mode=crop&scale=both",
                        );*/
