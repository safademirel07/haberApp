import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:haber/data/constants.dart';
import 'package:haber/widgets/others/form_picker.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  TextEditingController titleController;

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  bool _isCurrent = false;

  void submitForm() async {
    Navigator.pop(context);
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
                  obscureText: true,
                  maxLines: 1,
                  attribute: "oldPassword",
                  initialValue: "eski şifre",
                  decoration: InputDecoration(labelText: "Eski Şifre (*)"),
                  validators: [
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(Constants.minLengthShort),
                    FormBuilderValidators.maxLength(Constants.maxLengthShort),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FormBuilderTextField(
                  obscureText: true,
                  maxLines: 1,
                  attribute: "newPassword",
                  initialValue: "yenisifre",
                  decoration: InputDecoration(labelText: "Yeni Şifre (*)"),
                  validators: [
                    FormBuilderValidators.maxLength(Constants.maxLengthMiddle),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FormBuilderTextField(
                  obscureText: true,
                  maxLines: 1,
                  attribute: "newRePassword",
                  initialValue: "yenisifre",
                  decoration:
                      InputDecoration(labelText: "Yeni Şifre Tekrar (*)"),
                  validators: [
                    FormBuilderValidators.maxLength(Constants.maxLengthMiddle),
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
