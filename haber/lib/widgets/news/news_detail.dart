import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haber/app_theme.dart';
import 'package:haber/data/constants.dart';
import 'package:haber/data/sharedpref/shared_preference_helper.dart';
import 'package:haber/models/Comment.dart';
import 'package:haber/models/Firebase.dart';
import 'package:haber/models/News.dart';
import 'package:haber/models/NewsDetails.dart';
import 'package:haber/providers/comment_provider.dart';
import 'package:haber/providers/news_provider.dart';
import 'package:haber/providers/search_provider.dart';
import 'package:haber/providers/user_provider.dart';
import 'package:haber/widgets/comment/add_comment.dart';
import 'package:haber/widgets/comment/comment_element.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:swipedetector/swipedetector.dart';
import 'package:haber/widgets/others/full_screen_image.dart';

class NewsDetail extends StatefulWidget {
  @override
  _NewsDetailState createState() => _NewsDetailState();
}

class _NewsDetailState extends State<NewsDetail> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  bool favoritedAsAnonymous = false;

  Future<void> getMoreNews(int type, [List<String> categories]) {
    switch (type) {
      case Constants.newsTypeList:
        {
          List<String> news_sites =
              Provider.of<NewsProvider>(context, listen: false)
                  .getSelectedNewsSites();

          String sort = Provider.of<SearchProvider>(context, listen: false)
              .getSelectedSort()
              .toString();
          Provider.of<NewsProvider>(context, listen: false)
              .fetchListNews("", categories, news_sites, sort, true);
        }
        break;
      case Constants.newsTypeSlider:
        {
          List<String> news_sites =
              Provider.of<NewsProvider>(context, listen: false)
                  .getSelectedNewsSites();

          Provider.of<NewsProvider>(context, listen: false)
              .fetchSliderNews(news_sites, true);
        }
        break;
      case Constants.newsTypeFavorites:
        Provider.of<NewsProvider>(context, listen: false)
            .fetchFavoriteNews("", true);
        break;

      case Constants.newsTypeLiked:
        Provider.of<UserProvider>(context, listen: false)
            .fetchLikedNews("", true);
        break;
      case Constants.newsTypeDisliked:
        Provider.of<UserProvider>(context, listen: false)
            .fetchDislikedNews("", true);
        break;
      case Constants.newsTypecommented:
        Provider.of<UserProvider>(context, listen: false)
            .fetchCommentedNews("", true);
        break;

      default:
    }
  }

  void addToFavoritesAsAnonymous(String favoriteID) async {
    bool isExists = await favoriteExists(favoriteID);
    if (isExists) return;
    await SharedPreferenceHelper.addFavorites(favoriteID);

    setState(() {
      favoritedAsAnonymous = true;
    });
  }

  void removeFromFavoritesAsAnonymous(String favoriteID) async {
    bool isExists = await favoriteExists(favoriteID);
    if (!isExists) return;
    String favorites = await SharedPreferenceHelper.getFavorites;
    String replacedFavorites = favorites.replaceAll("$favoriteID,", "");
    await SharedPreferenceHelper.setFavorites(replacedFavorites);

    setState(() {
      favoritedAsAnonymous = false;
    });
  }

  Future<bool> favoriteExists(String favoriteId) async {
    String favorites = await SharedPreferenceHelper.getFavorites;

    if (favorites.length == 0) false;

    List<String> split = favorites.split(",");

    if (split.length == 0) false;

    return split.contains(favoriteId);
  }

  void changeFavoriteStatus(String favoriteID) async {
    bool isExists = await favoriteExists(favoriteID);
    if (isExists) {
      setState(() {
        favoritedAsAnonymous = true;
      });
    } else {
      setState(() {
        favoritedAsAnonymous = false;
      });
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NewsDetails details = ModalRoute.of(context).settings.arguments;
      int index = details.getIndex();

      int type = details.getType();
      List<News> listNews = List<News>();

      switch (type) {
        case Constants.newsTypeList:
          listNews =
              Provider.of<NewsProvider>(context, listen: false).getListNews();
          break;
        case Constants.newsTypeSlider:
          listNews =
              Provider.of<NewsProvider>(context, listen: false).getSliderNews();
          break;
        case Constants.newsTypeFavorites:
          listNews = Provider.of<NewsProvider>(context, listen: false)
              .getFavoriteNews();
          break;

        case Constants.newsTypeLiked:
          listNews =
              Provider.of<UserProvider>(context, listen: false).getLikedNews();
          break;
        case Constants.newsTypeDisliked:
          listNews = Provider.of<UserProvider>(context, listen: false)
              .getDislikedNews();
          break;
        case Constants.newsTypecommented:
          listNews = Provider.of<UserProvider>(context, listen: false)
              .getCommentedNews();
          break;
        case Constants.newsTypeSearch:
          listNews = Provider.of<SearchProvider>(context, listen: false)
              .getSearchNews();
          break;

        default:
      }

      final News news = listNews[index];

      print("initstate geldim" + news.sId);

      Provider.of<NewsProvider>(context, listen: false)
          .viewNews(news.sId, context);
      Provider.of<CommentProvider>(context, listen: false)
          .fetchComments(news.sId, false);

      changeFavoriteStatus(news.sId);
    });

    super.initState();
  }

  Future<void> refreshComments(String newsID) {
    return Provider.of<CommentProvider>(context, listen: false)
        .fetchComments(newsID, true);
  }

  Future<void> loadMoreComment(String newsID) {
    Provider.of<CommentProvider>(context, listen: false)
        .fetchComments(newsID, true);
  }

  @override
  Widget build(BuildContext context) {
    NewsDetails details = ModalRoute.of(context).settings.arguments;

    bool isSlider = details.isSlider();
    int index = details.getIndex();

    int type = details.getType();

    List<String> listType = details.getListType();

    List<News> listNews = List<News>();

    switch (type) {
      case Constants.newsTypeList:
        listNews =
            Provider.of<NewsProvider>(context, listen: true).getListNews();
        break;
      case Constants.newsTypeSlider:
        listNews =
            Provider.of<NewsProvider>(context, listen: true).getSliderNews();
        break;
      case Constants.newsTypeFavorites:
        listNews =
            Provider.of<NewsProvider>(context, listen: true).getFavoriteNews();
        break;

      case Constants.newsTypeLiked:
        listNews =
            Provider.of<UserProvider>(context, listen: true).getLikedNews();
        break;
      case Constants.newsTypeDisliked:
        listNews =
            Provider.of<UserProvider>(context, listen: true).getDislikedNews();
        break;
      case Constants.newsTypecommented:
        listNews =
            Provider.of<UserProvider>(context, listen: true).getCommentedNews();
        break;
      case Constants.newsTypeSearch:
        listNews =
            Provider.of<SearchProvider>(context, listen: true).getSearchNews();
        break;

      default:
    }

    final News news = listNews[index];

    final List<Comment> comments =
        Provider.of<CommentProvider>(context, listen: true).anyComment()
            ? Provider.of<CommentProvider>(context, listen: true).getComments()
            : List<Comment>();

    bool isLoadingComment =
        Provider.of<CommentProvider>(context, listen: true).isLoading;
    bool isLoadingCommentMore =
        Provider.of<CommentProvider>(context, listen: true).isLoadingMore;

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        body: SwipeDetector(
          onSwipeLeft: () async {
            if (index + 1 >= listNews.length) {
              showInSnackBar(
                  "Daha fazla haber yükleniyor, birazdan tekrar dene.");
              getMoreNews(type, listType);
              return;
            }
            News nextNews = listNews[index + 1];
            if (nextNews != null) {
              Navigator.pushReplacementNamed(
                context,
                "/detail",
                arguments: NewsDetails(index + 1, true, type, listType),
              );
            } else {
              showInSnackBar("Daha fazla ileriye gidemezsin.");
            }
          },
          onSwipeRight: () async {
            if (index - 1 < 0) {
              showInSnackBar("Daha fazla geriye gidemezsin.");
              return;
            }
            News previousNews = listNews[index - 1];
            if (previousNews != null) {
              Navigator.pushReplacementNamed(
                context,
                "/detail",
                arguments: NewsDetails(index - 1, true, type, listType),
              );
            } else {
              showInSnackBar("Daha fazla geriye gidemezsin.");
            }
          },
          child: RefreshIndicator(
            onRefresh: () async {
              refreshComments(news.sId);
            },
            child: NotificationListener(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent &&
                    !isLoadingComment &&
                    !isLoadingCommentMore) {
                  loadMoreComment(news.sId);
                }
              },
              child: ListView(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 8, right: 8, top: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Text(
                          news.title,
                          style: AppTheme.title,
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => FullScreenImage(
                                          news.image,
                                          "type_" +
                                              type.toString() +
                                              news.image +
                                              "_id$index")));
                            },
                            child: Hero(
                              tag: "type_" +
                                  type.toString() +
                                  news.image +
                                  "_id$index",
                              child: CachedNetworkImage(
                                errorWidget: (context, url, error) => Container(
                                    padding: EdgeInsets.all(4.0),
                                    child: Center(
                                      child: Text(
                                        "Haber fotoğrafı yüklenemedi.",
                                        textAlign: TextAlign.center,
                                        style: AppTheme.caption,
                                      ),
                                    )),
                                placeholder: (context, url) => Container(
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.0,
                                    ),
                                  ),
                                  padding: EdgeInsets.all(4.0),
                                ),
                                imageUrl: news.image,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Divider(
                          color: Colors.black,
                          height: 1,
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Column(
                          children: <Widget>[
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Icon(
                                        FontAwesomeIcons.newspaper,
                                      ),
                                      SizedBox(
                                        width: 6,
                                      ),
                                      Text(
                                        news.siteDetails.name,
                                        style: AppTheme.caption2Adaptive,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Icon(Icons.remove_red_eye),
                                      SizedBox(
                                        width: 2,
                                      ),
                                      Text(
                                        news.uniqueViews.toString(),
                                        style: AppTheme.caption2Adaptive,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      SizedBox(
                                        width: 4,
                                      ),
                                      InkWell(
                                          onTap: () {
                                            if (Constants.loggedIn &&
                                                Constants.anonymousLoggedIn ==
                                                    false &&
                                                Firebase().getUser() != null) {
                                              Provider.of<NewsProvider>(context,
                                                      listen: false)
                                                  .likeNews(news.sId, context);
                                            } else {
                                              showInSnackBar(
                                                  "Lütfen giriş yapın.");
                                            }
                                          },
                                          child: Icon(
                                            Icons.thumb_up,
                                            color: news.isLiked
                                                ? Colors.green[700]
                                                : Colors.black,
                                          )),
                                      SizedBox(
                                        width: 2,
                                      ),
                                      Text(
                                        news.likes.toString(),
                                        style: AppTheme.caption2Adaptive,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      SizedBox(
                                        width: 4,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          if (Constants.loggedIn &&
                                              Constants.anonymousLoggedIn ==
                                                  false &&
                                              Firebase().getUser() != null) {
                                            Provider.of<NewsProvider>(context,
                                                    listen: false)
                                                .dislikeNews(news.sId, context);
                                          } else {
                                            showInSnackBar(
                                                "Lütfen giriş yapın.");
                                          }
                                        },
                                        child: Icon(
                                          Icons.thumb_down,
                                          color: news.isDisliked
                                              ? Colors.red
                                              : Colors.black,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 2,
                                      ),
                                      Text(
                                        news.dislikes.toString(),
                                        style: AppTheme.caption2Adaptive,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Icon(Icons.access_time),
                                      SizedBox(
                                        width: 2,
                                      ),
                                      Text(
                                        news.date,
                                        style: AppTheme.caption2Adaptive,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Divider(
                              color: Colors.black,
                              height: 1,
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Container(
                              child: Text(
                                news.body,
                                style: AppTheme.captionMont,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Padding(
                          padding: EdgeInsets.zero,
                          child: Divider(
                            color: Colors.black,
                            height: 1,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                RaisedButton(
                                  elevation: 6,
                                  textColor: Colors.white,
                                  color: Colors.black,
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        news.isFavorited
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        size: 18,
                                      ),
                                      SizedBox(
                                        width: 3,
                                      ),
                                      Text(
                                        Constants.anonymousLoggedIn == true
                                            ? (favoritedAsAnonymous
                                                ? "Favorilerden Çıkar"
                                                : "Favorilere Ekle")
                                            : (news.isFavorited
                                                ? "Favorilerden Çıkar"
                                                : "Favorilere Ekle"),
                                        style: AppTheme.captionWhite,
                                      ),
                                    ],
                                  ),
                                  onPressed: () async {
                                    if (Constants.anonymousLoggedIn == true &&
                                        Firebase().getUser() != null) {
                                      bool isExist =
                                          await favoriteExists(news.sId);
                                      if (isExist) {
                                        removeFromFavoritesAsAnonymous(
                                            news.sId);
                                        showInSnackBar(
                                            "Anonim olarak silindi.");
                                      } else {
                                        addToFavoritesAsAnonymous(news.sId);
                                        showInSnackBar(
                                            "Anonim olarak eklendi.");
                                      }
                                    } else if (Constants.loggedIn &&
                                        Constants.anonymousLoggedIn == false &&
                                        Firebase().getUser() != null) {
                                      Provider.of<NewsProvider>(context,
                                              listen: false)
                                          .favoriteNews(news.sId, context);
                                    } else {
                                      showInSnackBar("Lütfen giriş yapın.");
                                    }
                                  },
                                  shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(16.0),
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                RaisedButton(
                                  elevation: 6,
                                  textColor: Colors.white,
                                  color: Colors.black,
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.open_in_browser,
                                        size: 18,
                                      ),
                                      SizedBox(
                                        width: 3,
                                      ),
                                      Text(
                                        "Aç",
                                        style: AppTheme.captionWhite,
                                      ),
                                    ],
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      "/browser",
                                      arguments: news,
                                    );
                                  },
                                  shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(16.0),
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                RaisedButton(
                                  elevation: 6,
                                  textColor: Colors.white,
                                  color: Colors.black,
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.share,
                                        size: 18,
                                      ),
                                      SizedBox(
                                        width: 3,
                                      ),
                                      Text(
                                        "Paylaş",
                                        style: AppTheme.captionWhite,
                                      ),
                                    ],
                                  ),
                                  onPressed: () {
                                    Share.share(
                                        news.body +
                                            " Haber Kaynağı: " +
                                            news.siteDetails.name +
                                            " Haber Adresi: " +
                                            news.link,
                                        subject: news.title);
                                  },
                                  shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(16.0),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        Divider(
                          color: Colors.black,
                          height: 1,
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            (Constants.loggedIn &&
                                    Constants.anonymousLoggedIn == false &&
                                    Firebase().getUser() != null)
                                ? AddComment(news.sId)
                                : Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Container(
                                      margin: EdgeInsets.all(8),
                                      child: Center(
                                        child: Text(
                                          "Haberlere yorum yapabilmek için lütfen giriş yapın.",
                                          style: AppTheme.captionMont,
                                        ),
                                      ),
                                    ),
                                  ),
                            SizedBox(
                              height: 8,
                            ),
                            if (comments.length == 0)
                              Text(
                                "Bu habere yorum yapılmamış.",
                                style: AppTheme.body2,
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                primary: false,
                                padding: EdgeInsets.zero,
                                itemCount: comments.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return CommentElement(comments[index]);
                                },
                              ),
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
