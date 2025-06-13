import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/list_page.dart';
import 'pages/write_page.dart';
import 'pages/detail_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: '하루 한 바닥',
      initialRoute: '/', // 홈 경로
      routes: {
        '/': (context) => HomePage(),
        '/list': (context) => ListPage(),
        '/write': (context) => WritePage(),
        '/detail': (context) => DetailPage(),
      },
    );
  }
}