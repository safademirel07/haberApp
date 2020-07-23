import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:haber/app_theme.dart';
import 'package:haber/data/constants.dart';
import 'package:haber/data/sharedpref/shared_preference_helper.dart';
import 'package:haber/models/Firebase.dart';
import 'package:haber/models/User.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool clickedLogin = false;

  Future<User> login(String _email, String _password) async {
    final http.Response response = await http.post(
      Constants.api_url + "/users/login",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(
        <String, String>{
          'email': _email.trim(),
          'password': _password,
        },
      ),
    );

    print("response.statusCode" + response.statusCode.toString());

    if (response.statusCode == 200) {
      try {
        var firebase = Firebase();

        await SharedPreferenceHelper.setUser(_email.trim());
        await SharedPreferenceHelper.setPassword(_password);

        await FirebaseAuth.instance.signOut();

        AuthCredential credential = EmailAuthProvider.getCredential(
            email: _email.trim(), password: _password);

        FirebaseUser signIn =
            (await _auth.signInWithCredential(credential)).user;

        firebase.setUser(signIn);

        print("Login sucess. Email " + signIn.email);

        Constants.loggedIn = true;

        return User.fromJson(json.decode(response.body), signIn.uid);
      } catch (e) {
        print("hata bu " + e);
        throw Future.error("Failed to login");
      }
    } else {
      throw Future.error("Failed to login");
    }
  }

  void submitForm() async {
    if (_fbKey.currentState.saveAndValidate()) {
      setState(() {
        clickedLogin = true;
      });
      login(_fbKey.currentState.value['email'],
              _fbKey.currentState.value['password'])
          .then(
        (user) {
          setState(() {
            clickedLogin = false;
            SharedPreferenceHelper.setAuthToken(user.token);
            SharedPreferenceHelper.setUID(user.uid);
            Navigator.pushNamed(
              context,
              "/home",
            );
          });
        },
        onError: (error) {
          setState(() {
            clickedLogin = false;
          });
          _scaffoldKey.currentState
              .showSnackBar(SnackBar(content: Text("Failed to login")));
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var padding = MediaQuery.of(context).padding; //Safe Area
    double screenHeight = MediaQuery.of(context).size.height - padding.top;

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        body: Container(
            child: Center(
                child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(32),
                child: Text(
                  "Login",
                  textAlign: TextAlign.center,
                  style: AppTheme.display1,
                ),
              ),
              FormBuilder(
                key: _fbKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      margin: EdgeInsets.only(bottom: 5),
                      child: FormBuilderTextField(
                        attribute: "email",
                        initialValue: "",
                        decoration: InputDecoration(
                          filled: true,
                          hintText: "Mail Address",
                          errorStyle: TextStyle(color: Colors.white),
                          hintStyle: TextStyle(color: Colors.grey),
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide:
                                BorderSide(color: Colors.white, width: 10),
                          ),
                        ),
                        validators: [
                          FormBuilderValidators.required(),
                          FormBuilderValidators.email(),
                          FormBuilderValidators.minLength(1),
                          FormBuilderValidators.maxLength(24),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      margin: EdgeInsets.only(bottom: 5),
                      child: FormBuilderTextField(
                        attribute: "password",
                        obscureText: true,
                        initialValue: "",
                        maxLines: 1,
                        decoration: InputDecoration(
                          filled: true,
                          hintText: "Password",
                          errorStyle: TextStyle(color: Colors.white),
                          hintStyle: TextStyle(color: Colors.grey),
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide:
                                BorderSide(color: Colors.white, width: 10),
                          ),
                        ),
                        validators: [
                          FormBuilderValidators.required(),
                          FormBuilderValidators.minLength(1),
                          FormBuilderValidators.maxLength(24),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            height: 50,
                            child: RaisedButton(
                              elevation: 3,
                              color: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: BorderSide(
                                    color: Colors.grey[600], width: 1),
                              ),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  "/register",
                                );
                              },
                              child: Text(
                                "REGISTER",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            height: 50,
                            child: RaisedButton(
                              elevation: 3,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: BorderSide(
                                    color: Colors.grey[600], width: 1),
                              ),
                              onPressed: () {
                                submitForm();
                              },
                              child: clickedLogin
                                  ? CircularProgressIndicator()
                                  : Text(
                                      "LOGIN",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ))),
      ),
    );
  }
}
