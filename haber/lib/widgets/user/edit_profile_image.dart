import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:haber/data/constants.dart';
import 'package:haber/widgets/others/form_picker.dart';

class EditProfileImage extends StatefulWidget {
  @override
  EditProfileImageState createState() => EditProfileImageState();
}

class EditProfileImageState extends State<EditProfileImage> {
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
                child: FormBuilderFilePicker(
                  attribute: "uploadImage",
                  decoration: InputDecoration(labelText: "Profil Fotoğrafı"),
                  previewImages: true,
                  onChanged: (val) => print(val),
                  fileType: FileType.image,
                  selector: Row(
                    children: <Widget>[
                      Icon(Icons.file_upload),
                      Text('Fotoğraf Seç'),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 10, bottom: 5),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    side: BorderSide(color: Colors.grey[600], width: 1),
                  ),
                  child: Text('Değiştir'),
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
