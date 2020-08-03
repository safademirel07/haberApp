import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Connection extends StatefulWidget {
  const Connection({Key key}) : super(key: key);

  @override
  _ConnectionState createState() => _ConnectionState();
}

class _ConnectionState extends State<Connection> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: new Text("İnternet Bağlantısı"),
      content: new Text(
          "İnternet bağlantısı yok, lütfen bağlandıktan sonra tekrar deneyin."),
      actions: <Widget>[
        new FlatButton(
          child: new Text("Kapat"),
          onPressed: () async {
            await SystemChannels.platform
                .invokeMethod<void>('SystemNavigator.pop', true);
          },
        ),
      ],
    );
  }
}
