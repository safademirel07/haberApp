import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Connection extends StatefulWidget {
  String title, body;

  Connection(this.title, this.body);

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
      title: new Text(widget.title),
      content: new Text(widget.body),
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
