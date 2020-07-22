import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:haber/app_theme.dart';
import 'package:haber/models/News.dart';

class NewsListElement extends StatefulWidget {
  News news;

  NewsListElement(this.news);

  @override
  _NewsListElementState createState() => _NewsListElementState();
}

class _NewsListElementState extends State<NewsListElement> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            "/detail",
            arguments: widget.news,
          );
        },
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 40,
              child: Material(
                child: Hero(
                  tag: widget.news.image,
                  child: CachedNetworkImage(
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
