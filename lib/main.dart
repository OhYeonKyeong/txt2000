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
      initialRoute: '/home',
      navigatorObservers: [routeObserver], // list 항상 새로고침
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/home':
            return MaterialPageRoute(builder: (_) => HomePage());
          case '/list':
            return MaterialPageRoute(builder: (_) => ListPage());
          case '/write':
            return MaterialPageRoute(
              builder: (_) => WritePage(),
              settings: settings,
            );
          case '/detail':
            return MaterialPageRoute(
              // detail_pags 에서 const DetailPage({super.key}); 선언 안하면 여기 오류남
              // 이유 ? MaterialPageRoute나 Navigator는 자동으로 Key를 넘기는데
              // 페이지가 그걸 받을 준비가 안 돼 있으면 컴파일러가 빨간줄 내는 거야!
              builder: (_) => DetailPage(),
              settings: settings,
            );
          default:
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(child: Text('404: 페이지를 찾을 수 없습니다')),
              ),
            );
        }
      },
    );
  }
}
