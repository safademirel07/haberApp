import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:haber/app_theme.dart';
import 'package:haber/models/News.dart';
import 'package:haber/models/NewsDetails.dart';
import 'package:haber/providers/comment_provider.dart';
import 'package:haber/providers/news_provider.dart';
import 'package:provider/provider.dart';

class NewsListElement extends StatefulWidget {
  News news;
  int index;
  int type;
  List<String> categories;

  //type == 1 > Slider
  //type == 2 > List
  //type == 3 > Favorites
  //type == 4 > Liked
  //type == 5 > Disliked
  //type == 6 > Commented

  NewsListElement(this.news, this.index, this.type, [this.categories]);

  @override
  _NewsListElementState createState() => _NewsListElementState();
}

class _NewsListElementState extends State<NewsListElement> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: InkWell(
        onTap: () async {
          await Provider.of<NewsProvider>(context, listen: false)
              .viewNews(widget.news.sId, context);
          await Provider.of<CommentProvider>(context, listen: false)
              .fetchListNews(widget.news.sId, false);

          Navigator.pushNamed(
            context,
            "/detail",
            arguments: NewsDetails(
                widget.index, false, widget.type, widget.categories),
          );
        },
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 40,
              child: Material(
                child: Hero(
                  tag: "type_" +
                      widget.type.toString() +
                      widget.news.image +
                      "_id" +
                      widget.index.toString(),
                  child: CachedNetworkImage(
                    errorWidget: (context, url, error) => Container(
                        child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Haber fotoğrafı yüklenemedi.",
                        style: AppTheme.caption,
                        textAlign: TextAlign.center,
                      ),
                    )),
                    placeholder: (context, url) => Container(
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 1.0,
                        ),
                      ),
                      padding: EdgeInsets.all(3.0),
                    ),
                    imageUrl: widget.news.image,
                    fit: BoxFit.cover,
                  ),
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
                clipBehavior: Clip.hardEdge,
              ),
            ),
            Expanded(
              flex: 60,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Container(
                      child: new Text(
                          widget.news.siteDetails.name +
                              ", " +
                              widget.news.categoryDetails.name,
                          maxLines: 2,
                          style: AppTheme.caption),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    new Container(
                      child: new Text(widget.news.title,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: AppTheme.title),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    new Container(
                      child: new Text(
                        widget.news.date,
                        style: AppTheme.caption,
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
