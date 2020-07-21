import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:haber/app_theme.dart';
import 'package:haber/models/News.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsDetail extends StatefulWidget {
  @override
  _NewsDetailState createState() => _NewsDetailState();
}

class _NewsDetailState extends State<NewsDetail> {
  @override
  Widget build(BuildContext context) {
    final News news = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                  child: CachedNetworkImage(
                    placeholder: (context, url) => Container(
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 1.0,
                        ),
                      ),
                      padding: EdgeInsets.all(3.0),
                    ),
                    imageUrl: news.image,
                    fit: BoxFit.cover,
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
                                "251",
                                style: AppTheme.caption2,
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              SizedBox(
                                width: 4,
                              ),
                              Icon(Icons.thumb_up),
                              SizedBox(
                                width: 2,
                              ),
                              Text(
                                "24",
                                style: AppTheme.caption2,
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              SizedBox(
                                width: 4,
                              ),
                              Icon(Icons.thumb_down),
                              SizedBox(
                                width: 2,
                              ),
                              Text(
                                "12",
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
                                "22 Temmuz 2020 18:50",
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
