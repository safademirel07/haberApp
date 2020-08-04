import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:haber/app_theme.dart';

class NewsShimmer extends StatelessWidget {
  const NewsShimmer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          Flexible(
            flex: 40,
            child: Material(
              child: Image.asset(
                "assets/images/shimmer.jpg",
                fit: BoxFit.fill,
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
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                      color: Colors.black,
                    ),
                    child: Center(
                      child: Text("Bu bir baslik",
                          maxLines: 2, style: AppTheme.caption),
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                        color: Colors.black,
                      ),
                      child: Center(
                          child: Text(
                              "Bu bir baslikBu bir baslikBu bir baslikBu bir baslikBu bir baslikBu bir baslikBu bir baslik",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: AppTheme.title))),
                  SizedBox(
                    height: 4,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                      color: Colors.black,
                    ),
                    child: Center(
                      child: Text("Bu bir tarih", style: AppTheme.caption),
                    ),
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
