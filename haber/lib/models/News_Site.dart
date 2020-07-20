class SiteDetails {
  String sId;
  String url;
  String name;
  String image;

  SiteDetails({this.sId, this.url, this.name, this.image});

  SiteDetails.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    url = json['url'];
    name = json['name'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['url'] = this.url;
    data['name'] = this.name;
    data['image'] = this.image;
    return data;
  }
}
