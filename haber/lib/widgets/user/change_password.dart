import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:haber/data/constants.dart';
import 'package:haber/providers/user_provider.dart';
import 'package:haber/widgets/others/form_picker.dart';
import 'package:provider/provider.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  TextEditingController titleController;

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  bool _isCurrent = false;

  bool _isObscure = true;

  get isObscure => _isObscure;

  set setObscure(value) {
    setState(() {
      _isObscure = value;
    });
  }

  void submitForm() async {
    if (_fbKey.currentState.saveAndValidate()) {
      String old_password = _fbKey.currentState.value['oldPassword'];
      String new_password = _fbKey.currentState.value['newPassword'];
      String re_new_password = _fbKey.currentState.value['newRePassword'];

      if (old_password != null &&
          new_password != null &&
          re_new_password != null) {
        String result = await Provider.of<UserProvider>(context, listen: false)
            .changePassword(
                old_password, new_password, re_new_password, context);

        if (result == "OK") {
          await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Başarılı"),
                  content: Text("Şifre başarıyla değiştirildi."),
                  actions: [
                    FlatButton(
                      child: Text("Tamam"),
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          "/profile",
                        );
                        return;
                      },
                    )
                  ],
                );
              });
        } else {
          await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Hata"),
                  content: Text(result),
                  actions: [
                    FlatButton(
                      child: Text("Tamam"),
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          "/profile",
                        );
                        return;
                      },
                    )
                  ],
                );
              });
        }
        //
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FormBuilder(
        key: _fbKey,
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FormBuilderTextField(
                  obscureText: _isObscure,
                  maxLines: 1,
                  attribute: "oldPassword",
                  initialValue: "",
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                          tooltip: "Şifreyi göster",
                          color: Colors.black,
                          onPressed: () {
                            setObscure = !isObscure;
                          },
                          icon: Icon(isObscure
                              ? Icons.visibility
                              : Icons.visibility_off)),
                      labelText: "Eski Şifre (*)"),
                  validators: [
                    FormBuilderValidators.required(
                        errorText: "Bu alanı boş bırakamazsınız."),
                    FormBuilderValidators.minLength(3,
                        errorText: "En az 6 karakter girmelisiniz"),
                    FormBuilderValidators.maxLength(24,
                        errorText: "En fazla 24 karakter girebilirsiniz"),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FormBuilderTextField(
                  obscureText: _isObscure,
                  maxLines: 1,
                  attribute: "newPassword",
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                        tooltip: "Şifreyi göster",
                        color: Colors.black,
                        onPressed: () {
                          setObscure = !isObscure;
                        },
                        icon: Icon(isObscure
                            ? Icons.visibility
                            : Icons.visibility_off),
                      ),
                      labelText: "Yeni Şifre (*)"),
                  validators: [
                    FormBuilderValidators.required(
                        errorText: "Bu alanı boş bırakamazsınız."),
                    FormBuilderValidators.minLength(3,
                        errorText: "En az 6 karakter girmelisiniz"),
                    FormBuilderValidators.maxLength(24,
                        errorText: "En fazla 24 karakter girebilirsiniz"),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FormBuilderTextField(
                  obscureText: _isObscure,
                  maxLines: 1,
                  attribute: "newRePassword",
                  initialValue: "",
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                        tooltip: "Şifreyi göster",
                        color: Colors.black,
                        onPressed: () {
                          setObscure = !isObscure;
                        },
                        icon: Icon(isObscure
                            ? Icons.visibility
                            : Icons.visibility_off),
                      ),
                      labelText: "Yeni Şifre Tekrar (*)"),
                  validators: [
                    FormBuilderValidators.required(
                        errorText: "Bu alanı boş bırakamazsınız."),
                    FormBuilderValidators.minLength(3,
                        errorText: "En az 6 karakter girmelisiniz"),
                    FormBuilderValidators.maxLength(24,
                        errorText: "En fazla 24 karakter girebilirsiniz"),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 10, bottom: 5),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    side: BorderSide(color: Colors.grey[600], width: 1),
                  ),
                  child: Text('Onayla'),
                  color: Colors.white,
                  textColor: Colors.black,
                  onPressed: () {
                    submitForm();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
