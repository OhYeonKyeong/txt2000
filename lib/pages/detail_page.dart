import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('상세 페이지'),
      ),
      body: Center(
        child: Text('선택한 글 상세보기'),
      ),
    );
  }
}