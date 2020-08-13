import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:haber/data/constants.dart';
import 'package:haber/data/sharedpref/shared_preference_helper.dart';
import 'package:haber/models/Firebase.dart';
import 'package:haber/models/User.dart';
import 'package:haber/providers/news_provider.dart';
import 'package:haber/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../app_theme.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User> register(
      String _name, String _email, String _password, String _password2) async {
    final http.Response response = await http.post(
      Constants.api_url + "/users/register",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(
        <String, String>{
          'name': _name,
          'email': _email,
          'password': _password,
          'password2': _password2,
        },
      ),
    );

    if (response.statusCode == 201) {
      Map<String, dynamic> result = json.decode(response.body);

      var firebase = Firebase();

      await SharedPreferenceHelper.setUser(_email.trim());
      await SharedPreferenceHelper.setPassword(_password);

      await FirebaseAuth.instance.signOut();

      AuthCredential credential = EmailAuthProvider.getCredential(
          email: _email.trim(), password: _password);

      FirebaseUser signIn = (await _auth.signInWithCredential(credential)).user;

      firebase.setUser(signIn);

      print("Register and login success. Email " + signIn.email);

      Constants.anonymousLoggedIn = false;
      Constants.loggedIn = true;

      User loggedInUser = User.fromJson(json.decode(response.body), signIn.uid);

      Provider.of<UserProvider>(context, listen: false).setUser(loggedInUser);
      Provider.of<NewsProvider>(context, listen: false)
          .setrequiredToFetchAgain = true;
      Provider.of<NewsProvider>(context, listen: false)
          .setRequiredToFetchAgainFavorites = true;
      Provider.of<NewsProvider>(context, listen: false).setAnonymous = false;

      return User.fromJson(json.decode(response.body), signIn.uid);
    } else {
      throw response.body;
    }
  }

  bool _isCurrent = false;

  bool clickedLogin = false;

  bool _isObscure = true;

  get isObscure => _isObscure;

  set setObscure(value) {
    setState(() {
      _isObscure = value;
    });
  }

  void submitForm() async {
    if (_fbKey.currentState.saveAndValidate()) {
      setState(() {
        clickedLogin = true;
      });
      try {
        register(
                //_fbKey.currentState.value['name'],
                _fbKey.currentState.value['name'],
                _fbKey.currentState.value['email'],
                _fbKey.currentState.value['password'],
                _fbKey.currentState.value['password2'])
            .then(
          (user) {
            setState(() {
              clickedLogin = false;
              SharedPreferenceHelper.setAuthToken(user.token);
              Navigator.pushNamed(
                context,
                "/home",
              );
            });
          },
          onError: (value) {
            Map<String, dynamic> result = json.decode(value);
            setState(() {
              clickedLogin = false;
            });
            _scaffoldKey.currentState
                .showSnackBar(SnackBar(content: Text(result["error"])));
          },
        ).catchError((onError) {});
      } catch (e) {
        _scaffoldKey.currentState
            .showSnackBar(SnackBar(content: Text("Failed to register")));
        setState(() {
          clickedLogin = false;
        });
      }

      //Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    var padding = MediaQuery.of(context).padding; //Safe Area
    double screenHeight = MediaQuery.of(context).size.height - padding.top;

    return Scaffold(
      key: _scaffoldKey,
      body: Center(
          child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(32),
              child: Text(
                "Kaydol",
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
                      attribute: "name",
                      initialValue: "",
                      decoration: InputDecoration(
                        filled: true,
                        hintText: "Kullanıcı adınız (*)",
                        errorStyle: GoogleFonts.montserrat(color: Colors.black),
                        hintStyle: GoogleFonts.montserrat(color: Colors.grey),
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide:
                              BorderSide(color: Colors.white, width: 10),
                        ),
                      ),
                      validators: [
                        FormBuilderValidators.required(
                            errorText: "Bu alanı boş bırakamazsınız."),
                        FormBuilderValidators.minLength(3,
                            errorText: "En az 3 karakter girmelisiniz"),
                        FormBuilderValidators.maxLength(24,
                            errorText: "En fazla 24 karakter girebilirsiniz"),
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
                      attribute: "email",
                      initialValue: "",
                      decoration: InputDecoration(
                        filled: true,
                        hintText: "Mail adresiniz (*)",
                        errorStyle: GoogleFonts.montserrat(color: Colors.black),
                        hintStyle: GoogleFonts.montserrat(color: Colors.grey),
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide:
                              BorderSide(color: Colors.white, width: 10),
                        ),
                      ),
                      validators: [
                        FormBuilderValidators.required(
                            errorText: "Bu alanı boş bırakamazsınız."),
                        FormBuilderValidators.email(
                            errorText: "Bir mail adresi girin."),
                        FormBuilderValidators.minLength(3,
                            errorText: "En az 3 karakter girmelisiniz"),
                        FormBuilderValidators.maxLength(120,
                            errorText: "En fazla 120 karakter girebilirsiniz"),
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
                      obscureText: _isObscure,
                      initialValue: "",
                      maxLines: 1,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          tooltip: "Şifreyi göster",
                          color: Colors.black,
                          onPressed: () {
                            setObscure = !isObscure;
                          },
                          icon: Icon(Icons.remove_red_eye),
                        ),
                        filled: true,
                        hintText: "Şifreniz (*)",
                        errorStyle: GoogleFonts.montserrat(color: Colors.black),
                        hintStyle: GoogleFonts.montserrat(color: Colors.grey),
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide:
                              BorderSide(color: Colors.white, width: 10),
                        ),
                      ),
                      validators: [
                        FormBuilderValidators.required(
                            errorText: "Bu alanı boş bırakamazsınız."),
                        FormBuilderValidators.minLength(3,
                            errorText: "En az 3 karakter girmelisiniz"),
                        FormBuilderValidators.maxLength(24,
                            errorText: "En fazla 24 karakter girebilirsiniz"),
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
                      attribute: "password2",
                      obscureText: _isObscure,
                      initialValue: "",
                      maxLines: 1,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          tooltip: "Şifreyi göster",
                          color: Colors.black,
                          onPressed: () {
                            setObscure = !isObscure;
                          },
                          icon: Icon(Icons.remove_red_eye),
                        ),
                        filled: true,
                        hintText: "Şifreniz (Tekrar) (*)",
                        errorStyle: GoogleFonts.montserrat(color: Colors.black),
                        hintStyle: GoogleFonts.montserrat(color: Colors.grey),
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide:
                              BorderSide(color: Colors.white, width: 10),
                        ),
                      ),
                      validators: [
                        FormBuilderValidators.required(
                            errorText: "Bu alanı boş bırakamazsınız."),
                        FormBuilderValidators.minLength(3,
                            errorText: "En az 3 karakter girmelisiniz"),
                        FormBuilderValidators.maxLength(24,
                            errorText: "En fazla 24 karakter girebilirsiniz"),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    height: 50,
                    child: RaisedButton(
                      elevation: 3,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(color: Colors.grey[600], width: 1),
                      ),
                      onPressed: () {
                        submitForm();
                      },
                      child: clickedLogin
                          ? CircularProgressIndicator()
                          : Text(
                              "Kaydol",
                              style: GoogleFonts.montserrat(
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
      )),
    );
  }
}
