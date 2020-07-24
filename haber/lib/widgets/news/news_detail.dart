import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haber/app_theme.dart';
import 'package:haber/data/constants.dart';
import 'package:haber/models/Firebase.dart';
import 'package:haber/models/News.dart';
import 'package:haber/models/NewsDetails.dart';
import 'package:haber/providers/news_provider.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

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

  @override
  Widget build(BuildContext context) {
    NewsDetails details = ModalRoute.of(context).settings.arguments;

    bool isSlider = details.isSlider();
    int index = details.getIndex();

    List<News> listNews = isSlider
        ? Provider.of<NewsProvider>(context, listen: true).getSliderNews()
        : Provider.of<NewsProvider>(context, listen: true).getListNews();

    final News news = listNews[index];

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(left: 8, right: 8, top: 8),
            child: Column(
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
                  child: Hero(
                    tag: (isSlider ? "slider_" : "list_") + news.image,
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
                      fit: BoxFit.cover,
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                style: AppTheme.caption2,
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
                                news.viewers.toString(),
                                style: AppTheme.caption2,
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
                                        Firebase().getUser() != null) {
                                      Provider.of<NewsProvider>(context,
                                              listen: false)
                                          .likeNews(news.sId);
                                    } else {
                                      showInSnackBar("Lütfen giriş yapın.");
                                    }
                                  },
                                  child: Icon(Icons.thumb_up)),
                              SizedBox(
                                width: 2,
                              ),
                              Text(
                                news.likes.toString(),
                                style: AppTheme.caption2,
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
                                        Firebase().getUser() != null) {
                                      Provider.of<NewsProvider>(context,
                                              listen: false)
                                          .dislikeNews(news.sId);
                                    } else {
                                      showInSnackBar("Lütfen giriş yapın.");
                                    }
                                  },
                                  child: Icon(Icons.thumb_down)),
                              SizedBox(
                                width: 2,
                              ),
                              Text(
                                news.dislikes.toString(),
                                style: AppTheme.caption2,
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
                                style: AppTheme.caption2,
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
                          textColor: Colors.white,
                          color: Colors.black,
                          child: Row(children: <Widget>[
                            Icon(Icons.open_in_browser),
                            SizedBox(
                              width: 5,
                            ),
                            Text("Habere Git"),
                          ]),
                          onPressed: () async {
                            if (await canLaunch(news.link)) {
                              await launch(news.link);
                            } else {
                              throw 'Could not launch' + news.link;
                            }
                          },
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(16.0),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        RaisedButton(
                          textColor: Colors.white,
                          color: Colors.black,
                          child: Row(children: <Widget>[
                            Icon(Icons.share),
                            SizedBox(
                              width: 5,
                            ),
                            Text("Paylaş"),
                          ]),
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
                            borderRadius: new BorderRadius.circular(16.0),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
