import 'package:haber/models/Category.dart';
import 'package:haber/models/News_Site.dart';
import 'package:haber/models/RSS.dart';

class News {
  String sId;
  int viewers;
  String title;
  String description;
  String body;
  String date;
  String link;
  String image;
  RssDetails rssDetails;
  SiteDetails siteDetails;
  CategoryDetails categoryDetails;
  int likes;
  int dislikes;
  bool isLiked;
  bool isDisliked;
  bool isFavorited;

  News(
      {this.sId,
      this.viewers,
      this.title,
      this.description,
      this.body,
      this.date,
      this.link,
      this.image,
      this.rssDetails,
      this.siteDetails,
      this.categoryDetails,
      this.likes,
      this.dislikes,
      this.isLiked,
      this.isDisliked,
      this.isFavorited});

  News.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    viewers = json['viewers'];
    title = json['title'];
    description = json['description'];
    body = json['body'];
    date = json['date'];
    link = json['link'];
    image = json['image'];
    isLiked = json['isLiked'];
    isDisliked = json['isDisliked'];
    isFavorited = json['isFavorited'];

    rssDetails = json['rssDetails'] != null
        ? new RssDetails.fromJson(json['rssDetails'])
        : null;
    siteDetails = json['siteDetails'] != null
        ? new SiteDetails.fromJson(json['siteDetails'])
        : null;
    categoryDetails = json['categoryDetails'] != null
        ? new CategoryDetails.fromJson(json['categoryDetails'])
        : null;
    likes = json['likes'];
    dislikes = json['dislikes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['viewers'] = this.viewers;
    data['title'] = this.title;
    data['description'] = this.description;
    data['body'] = this.body;
    data['date'] = this.date;
    data['link'] = this.link;
    data['image'] = this.image;
    if (this.rssDetails != null) {
      data['rssDetails'] = this.rssDetails.toJson();
    }
    if (this.siteDetails != null) {
      data['siteDetails'] = this.siteDetails.toJson();
    }
    if (this.categoryDetails != null) {
      data['categoryDetails'] = this.categoryDetails.toJson();
    }
    data['likes'] = this.likes;
    data['dislikes'] = this.dislikes;

    data['is_liked'] = this.isLiked;
    data['isDisliked'] = this.isDisliked;
    data['isFavorited'] = this.isFavorited;

    return data;
  }
}
