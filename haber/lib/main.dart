import 'package:flutter/material.dart';
import 'package:haber/models/NewsTest.dart';
import 'package:haber/widgets/news/news_slider.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'haberApp',
    initialRoute: '/news_slider',
    routes: {
      '/news_slider': (context) => NewsSlider(),
    },
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("haberApp"),
        ),
        body: Text("test"),
      ),
    );
  }
}
