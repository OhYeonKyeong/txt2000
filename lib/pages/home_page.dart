import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '한 바닥',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '오늘의 글을 남겨보세요.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 40),

              buildTextMenuItem(
                label: '글 목록 보기',
                onTap: () => Navigator.pushNamed(context, '/list'),
              ),
              const Divider(indent: 32, endIndent: 32),
              buildTextMenuItem(
                label: '새 글 작성하기',
                onTap: () => Navigator.pushNamed(context, '/write'),
              ),
              const Divider(indent: 32, endIndent: 32),
              buildTextMenuItem(
                label: '설정',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('설정은 아직 준비 중입니다.')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 텍스트 기반 메뉴 항목
  Widget buildTextMenuItem({
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          label,
          style: const TextStyle(fontSize: 18.0),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
