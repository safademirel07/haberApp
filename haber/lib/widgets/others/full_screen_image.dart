import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  String heroTag = "profilFotografi";

  FullScreenImage(this.imageUrl, [this.heroTag]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fotoğraf"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          child: Hero(
            tag: this.heroTag == null ? "profilFotografi" : this.heroTag,
            child: CachedNetworkImage(
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) =>
                  Image.asset("assets/images/default.png"),
              fit: BoxFit.contain,
              imageUrl: imageUrl,
            ),
          ),
        ),
      ),
    );
  }
}
