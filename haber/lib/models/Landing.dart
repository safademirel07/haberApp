class Landing {
  int type;
  String title;
  String description;
  String titleColor;
  String descripColor;
  String imagePath;

  Landing(
      {this.type,
      this.title,
      this.description,
      this.titleColor,
      this.descripColor,
      this.imagePath});

  Landing.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    title = json['title'];
    description = json['description'];
    titleColor = json['titleColor'];
    descripColor = json['descripColor'];
    imagePath = json['imagePath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['title'] = this.title;
    data['description'] = this.description;
    data['titleColor'] = this.titleColor;
    data['descripColor'] = this.descripColor;
    data['imagePath'] = this.imagePath;
    return data;
  }
}
