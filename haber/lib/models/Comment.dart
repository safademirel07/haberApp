class Comment {
  int date;
  String sId;
  String user;
  String news;
  String text;
  String userName;
  String userPhoto;

  Comment(
      {this.date,
      this.sId,
      this.user,
      this.news,
      this.text,
      this.userName,
      this.userPhoto});

  Comment.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    sId = json['_id'];
    user = json['user'];
    news = json['news'];
    text = json['text'];
    userName = json['userName'];
    userPhoto = json['userPhoto'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    data['_id'] = this.sId;
    data['user'] = this.user;
    data['news'] = this.news;
    data['text'] = this.text;
    data['userName'] = this.userName;
    data['userPhoto'] = this.userPhoto;
    return data;
  }
}
