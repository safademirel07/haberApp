class NewsTest {
  String sId;
  String title;
  String description;
  String body;
  String date;
  String link;
  String image;
  String newsSiteName;
  String newsCategoryName;

  NewsTest(
      {this.sId,
      this.title,
      this.description,
      this.body,
      this.date,
      this.link,
      this.image,
      this.newsSiteName,
      this.newsCategoryName});

  NewsTest.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    description = json['description'];
    body = json['body'];
    date = json['date'];
    link = json['link'];
    image = json['image'];
    newsSiteName = json['newsSiteName'];
    newsCategoryName = json['newsCategoryName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['title'] = this.title;
    data['description'] = this.description;
    data['body'] = this.body;
    data['date'] = this.date;
    data['link'] = this.link;
    data['image'] = this.image;
    data['newsSiteName'] = this.newsSiteName;
    data['newsCategoryName'] = this.newsCategoryName;
    return data;
  }
}
