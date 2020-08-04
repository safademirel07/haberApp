import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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
                children: <Widget>[
                  Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                        color: Colors.black,
                      ),
                      child: Center(
                          child: Text(
                              "Bu bir baslikBu bir baslikBu bir baslikBu bir baslikBu bir baslikBu bir baslik"))),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                        color: Colors.black,
                      ),
                      child: Center(child: Text("Bu bir baslikBu bir baslik"))),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
