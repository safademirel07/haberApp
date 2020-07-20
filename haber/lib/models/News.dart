import 'package:haber/models/Category.dart';
import 'package:haber/models/News_Site.dart';
import 'package:haber/models/RSS.dart';

class News {
  String sId;
  String rss;
  String title;
  String description;
  String body;
  String date;
  String link;
  String image;
  int iV;
  RssDetails rssDetails;
  SiteDetails siteDetails;
  CategoryDetails categoryDetails;

  News(
      {this.sId,
      this.rss,
      this.title,
      this.description,
      this.body,
      this.date,
      this.link,
      this.image,
      this.iV,
      this.rssDetails,
      this.siteDetails,
      this.categoryDetails});

  News.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    rss = json['rss'];
    title = json['title'];
    description = json['description'];
    body = json['body'];
    date = json['date'];
    link = json['link'];
    image = json['image'];
    iV = json['__v'];
    rssDetails = json['rssDetails'] != null
        ? new RssDetails.fromJson(json['rssDetails'])
        : null;
    siteDetails = json['siteDetails'] != null
        ? new SiteDetails.fromJson(json['siteDetails'])
        : null;
    categoryDetails = json['categoryDetails'] != null
        ? new CategoryDetails.fromJson(json['categoryDetails'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['rss'] = this.rss;
    data['title'] = this.title;
    data['description'] = this.description;
    data['body'] = this.body;
    data['date'] = this.date;
    data['link'] = this.link;
    data['image'] = this.image;
    data['__v'] = this.iV;
    if (this.rssDetails != null) {
      data['rssDetails'] = this.rssDetails.toJson();
    }
    if (this.siteDetails != null) {
      data['siteDetails'] = this.siteDetails.toJson();
    }
    if (this.categoryDetails != null) {
      data['categoryDetails'] = this.categoryDetails.toJson();
    }
    return data;
  }
}
