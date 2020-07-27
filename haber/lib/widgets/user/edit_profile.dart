import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:haber/data/constants.dart';
import 'package:haber/widgets/others/form_picker.dart';
import 'package:haber/widgets/user/change_password.dart';

class EditProfile extends StatefulWidget {
  @override
  EditProfileState createState() => EditProfileState();
}

class EditProfileState extends State<EditProfile> {
  TextEditingController titleController;

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  bool _isCurrent = false;

  void submitForm() async {
    Navigator.pop(context);
  }

  void _changePassword(
    BuildContext ctx,
  ) {
    Navigator.pop(context);
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
      elevation: 10,
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: ChangePassword(),
          behavior: HitTestBehavior.opaque,
        );
      },
    );
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
                  attribute: "username",
                  initialValue: "username",
                  decoration: InputDecoration(labelText: "Kullanıcı Adı (*)"),
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
                  attribute: "email",
                  initialValue: "widget.iCompanyName",
                  decoration: InputDecoration(labelText: "Email"),
                  validators: [
                    FormBuilderValidators.maxLength(Constants.maxLengthMiddle),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 10, bottom: 5),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: BorderSide(color: Colors.grey[600], width: 1),
                      ),
                      child: Text('Şifre Değiştir'),
                      color: Colors.white,
                      textColor: Colors.black,
                      onPressed: () {
                        _changePassword(context);
                      },
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
            ],
          ),
        ),
      ),
    );
  }
}
