import 'package:firebase_auth/firebase_auth.dart';

class Firebase {
  static final Firebase _singleton = Firebase._internal();

  FirebaseUser user;
  bool _isAnonymous;

  factory Firebase() {
    return _singleton;
  }

  setUser(FirebaseUser _user, [bool isAnonymous = false]) {
    _isAnonymous = isAnonymous;
    user = _user;
  }

  FirebaseUser getUser() {
    return user;
  }

  bool isAnonymous() {
    return _isAnonymous;
  }

  Firebase._internal();
}
