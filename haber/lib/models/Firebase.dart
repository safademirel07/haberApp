import 'package:firebase_auth/firebase_auth.dart';

class Firebase {
  static final Firebase _singleton = Firebase._internal();

  FirebaseUser user;

  factory Firebase() {
    return _singleton;
  }

  setUser(FirebaseUser _user) {
    user = _user;
  }

  FirebaseUser getUser() {
    return user;
  }

  Firebase._internal();
}
