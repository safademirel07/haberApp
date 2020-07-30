import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:haber/data/constants.dart';
import 'package:haber/models/Firebase.dart';
import 'package:haber/providers/user_provider.dart';
import 'package:haber/widgets/others/form_picker.dart';
import 'package:provider/provider.dart';

class EditProfileImage extends StatefulWidget {
  @override
  EditProfileImageState createState() => EditProfileImageState();
}

class EditProfileImageState extends State<EditProfileImage> {
  TextEditingController titleController;

  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  bool _isCurrent = false;

  final FirebaseStorage _storage =
      FirebaseStorage(storageBucket: 'gs://haberapp-54a0c.appspot.com');

  StorageUploadTask _uploadTask;

  bool _loading = false;

  void submitForm() async {
    if (_fbKey.currentState.saveAndValidate()) {
      if (_fbKey.currentState.value['uploadImage'] != null &&
          _fbKey.currentState.value['uploadImage'].toString().length > 0) {
        var path =
            Map<String, String>.from(_fbKey.currentState.value['uploadImage'])
                .values
                .toList();

        if (path.length > 0) {
          File imageFile = new File(path[0]);
          if (Constants.loggedIn && Firebase().getUser() != null) {
            String filePath = 'images/${Firebase().getUser().uid}.png';
            StorageReference storageReference = _storage.ref().child(filePath);

            _uploadTask = storageReference.putFile(imageFile);
            setState(() {
              _loading = true;
            });
            await _uploadTask.onComplete;
            storageReference.getDownloadURL().then((fileURL) {
              print("fileUrl " + fileURL);
              setState(() {
                _loading = false;
              });
              Provider.of<UserProvider>(context, listen: false)
                  .changeProfilePhoto(fileURL);
              Navigator.pop(context);
            });
          }
        }
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Visibility(
                    visible: _loading,
                    child: Container(
                      margin: EdgeInsets.only(left: 10, bottom: 5),
                      child: Row(
                        children: <Widget>[
                          Text('Yükleniyor'),
                          SizedBox(width: 10),
                          CircularProgressIndicator(),
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
            ],
          ),
        ),
      ),
    );
  }
}
