import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:txt2000/database/db_helper.dart';
import 'package:txt2000/models/text_model.dart';
import 'package:txt2000/widgets/dialog.dart';
import '../widgets/common_page_wrapper.dart';

/// 상세 페이지 - 특정 글(seq)을 보여주고, 수정 및 삭제 기능 제공
class DetailPage extends StatefulWidget {
  final int seq;

  /// 생성자에서 글 고유번호(seq)를 필수로 받음
  const DetailPage({super.key, required this.seq});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final DBHelper _dbHelper = DBHelper();

  TextModel? _textData; // DB에서 로드된 글 데이터
  bool _isLoading = true; // 로딩 상태 표시용

  @override
  void initState() {
    super.initState();
    // 위젯 초기화 시점에 seq로 글 데이터 로드 시작
    _loadText(widget.seq);
  }

  /// DB에서 seq에 해당하는 글 정보를 비동기로 가져오는 함수
  /// seq: 불러올 글 고유번호
  Future<void> _loadText(int seq) async {
    final result = await _dbHelper.getTextBySeq(seq);

    if (!mounted) return; // 위젯이 화면에서 사라졌다면 상태 갱신 중단

    setState(() {
      _textData = result;
      _isLoading = false;
    });
  }

  /// 삭제 전 사용자 확인 다이얼로그를 띄우고,
  /// 사용자가 확인하면 DB에서 글을 삭제한 후 리스트 화면으로 이동
  /// context: 현재 위젯의 BuildContext
  void _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('삭제하시겠습니까?'),
        content: const Text('삭제한 글은 복구할 수 없어요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    // 취소했으면 바로 리턴
    if (confirmed != true) return;

    try {
      final deleteRows = await _dbHelper.deleteText(_textData!.seq!);

      if (!mounted) return;

      if (deleteRows > 0) {
        // 삭제 성공 시 리스트 화면으로 이동 (goRouter 사용)
        context.go('/list');
      }
    } catch (e) {
      // 삭제 중 오류 발생 시 에러 다이얼로그 표시
      if (mounted) {
        await showDeleteErrorDialog(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _textData == null
          ? const Center(child: Text('글을 찾을 수 없습니다.'))
          : PageWrapper(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 글 제목
            Text(
              _textData!.title,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // 수정 및 삭제 버튼 모음
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    if (_textData == null) return;
                    // 수정 화면으로 이동, 편집 모드 및 기존 데이터 전달
                    context.push(
                      '/write',
                      extra: {
                        'mode': 'edit',
                        'text': _textData,
                      },
                    );
                  },
                  icon: const Icon(Icons.edit_outlined,
                      color: Colors.blue),
                  label: const Text('수정',
                      style: TextStyle(color: Colors.blue)),
                ),
                const SizedBox(width: 4),
                TextButton.icon(
                  onPressed: () => _confirmDelete(context),
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.red),
                  label: const Text('삭제',
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            ),

            // 글 내용
            Text(
              _textData!.content,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}