import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages/home_page.dart';
import 'pages/list_page.dart';
import 'pages/write_page.dart';
import 'pages/detail_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GoRouter _router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/list',
        name: 'list',
        builder: (context, state) => const ListPage(),
      ),
      GoRoute(
        path: '/write',
        name: 'write',
        builder: (context, state) => const WritePage(),
      ),
      GoRoute(
        path: '/detail/:seq',  // seq는 경로 파라미터
        name: 'detail',
        builder: (context, state) {
          final seq = state.pathParameters['seq']!;
          return DetailPage(seq: int.parse(seq));
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('404: 페이지를 찾을 수 없습니다.')),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
