import 'package:haber/data/sharedpref/shared_preference_helper.dart';

class User {
  String sId;
  String name;
  String email;
  String photoUrl;
  String token;
  String uid;

  User({this.sId, this.name, this.email, this.photoUrl, this.token, this.uid});

  SharedPreferenceHelper sharedPreferenceHelper;

  User.fromJson(Map<String, dynamic> json, String _uid) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    photoUrl = json['photoUrl'];
    token = json['token'];
    uid = _uid;
    //sharedPreferenceHelper.saveAuthToken(token);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['photoUrl'] = this.photoUrl;
    data['token'] = this.token;
    return data;
  }
}
