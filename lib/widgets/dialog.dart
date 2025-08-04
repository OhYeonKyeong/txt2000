import 'package:flutter/material.dart';

// 메시지 기능
Future<void> showSaveErrorDialog(BuildContext context) async {
  // 화면이 이미 닫힌 경우 다이얼로그 생략
  if (!context.mounted) return;

  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      content: Text('저장 중 오류가 발생했습니다.\n조건을 확인해주세요.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('확인'),
        ),
      ],
    ),
  );
}

// 메시지 기능
Future<void> showDeleteErrorDialog(BuildContext context) async {
  // 화면이 이미 닫힌 경우 다이얼로그 생략
  if (!context.mounted) return;

  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      content: Text('삭제에 실패했습니다.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('확인'),
        ),
      ],
    ),
  );
}

