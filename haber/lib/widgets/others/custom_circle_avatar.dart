import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CustomCircleAvatar extends StatelessWidget {
  final int animationDuration;
  final double radius;
  final String imagePath;

  const CustomCircleAvatar(
      {Key key, this.animationDuration, this.radius, this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new AnimatedContainer(
      duration: new Duration(
        milliseconds: animationDuration,
      ),
      constraints: new BoxConstraints(
        minHeight: radius,
        maxHeight: radius,
        minWidth: radius,
        maxWidth: radius,
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) =>
              Image.asset("assets/images/default.png"),
          fit: BoxFit.cover,
          imageUrl: imagePath,
        ),
      ),
    );
  }
}
