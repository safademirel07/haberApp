class NewsTest {
  String link;
  String title;
  String description;
  String date;
  String image;

  NewsTest({this.link, this.title, this.description, this.date, this.image});

  NewsTest.fromJson(Map<String, dynamic> json) {
    link = json['link'];
    title = json['title'];
    description = json['description'];
    date = json['date '];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['link'] = this.link;
    data['title'] = this.title;
    data['description'] = this.description;
    data['date '] = this.date;
    data['image'] = this.image;
    return data;
  }
}
