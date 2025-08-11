import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:txt2000/database/db_helper.dart';
import '../models/text_model.dart';
import '../widgets/common_page_wrapper.dart';
import '../widgets/dialog.dart';

class WritePage extends StatefulWidget {
  const WritePage({super.key});

  @override
  _WritePageState createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {
  // DBHelper 싱글톤 인스턴스
  final DBHelper _dbHelper = DBHelper();

  // 텍스트 컨트롤러 - 제목과 내용 입력 관리
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  // 공백 포함 여부를 토글하는 상태 변수
  bool _includeSpaces = true;

  // 글자 수 제한 변수 및 계산 (허용 범위 +/- 10%)
  final int _baseCharCount = 20;
  final double _tolerance = 0.1;
  int get minTxt => (_baseCharCount * (1 - _tolerance)).round();
  int get maxTxt => (_baseCharCount * (1 + _tolerance)).round();

  // 수정 모드인지 여부, 수정 대상 데이터 저장
  bool _isEditMode = false;
  TextModel? _textData;

  /// didChangeDependencies에서 파라미터 수신 후 초기값 세팅
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is Map && args['mode'] == 'edit') {
      _isEditMode = true;
      _textData = args['text'];

      _titleController.text = _textData?.title ?? '';
      _contentController.text = _textData?.content ?? '';
    }
  }

  /// 현재 입력 내용에 따라 글자 수 계산 (공백 포함 여부에 따라 다름)
  int _getCharCount() {
    if (_includeSpaces) {
      return _contentController.text.length;
    } else {
      return _contentController.text.replaceAll(RegExp(r'\s+'), '').length;
    }
  }

  /// 글자 수가 제한 범위 내에 있을 경우 초록색, 아니면 빨강색 반환
  Color _getCountColor() {
    final count = _getCharCount();
    if (count >= minTxt && count <= maxTxt) {
      return const Color(0xFF81C784); // 초록 (유효)
    } else {
      return const Color(0xFFE57373); // 빨강 (무효)
    }
  }

  /// 글자 수가 유효한지 여부 판단
  bool _isCharCountValid() {
    final count = _getCharCount();
    return count >= minTxt && count <= maxTxt;
  }

  /// 텍스트 저장 처리 (신규 또는 수정)
  /// 반환값: 성공 시 DB 행 id, 실패 시 -1
  Future<int> _saveText() async {
    String saveTitle = _titleController.text.trim();
    String saveContent = _contentController.text.trim();

    // 제목이 없으면 현재 날짜를 기본 제목으로 설정
    if (saveTitle.isEmpty) {
      final now = DateFormat('yyyy-MM-dd').format(DateTime.now());
      saveTitle = "$now 에 쓴 글";
    }

    final sysdate = DateTime.now().toIso8601String();
    int returnRow = -1;

    try {
      if (_isEditMode) {
        // 수정 모드 - 기존 seq 유지하며 업데이트
        final updated = TextModel(
          seq: _textData!.seq,
          title: saveTitle,
          content: saveContent,
          createdAt: _textData!.createdAt,
          modifiedAt: sysdate,
        );

        setState(() {
          _textData = updated;
        });

        returnRow = await _dbHelper.updateText(updated);
        if (!mounted) {
          return -1;
        }
        context.go('/list'); // 저장 후 리스트로 이동
      } else {
        // 신규 글 저장
        final created = TextModel(
          title: saveTitle,
          content: saveContent,
          createdAt: sysdate,
          modifiedAt: sysdate,
        );

        returnRow = await _dbHelper.insertText(created);
        if (!mounted) {
          return -1;
        }
        context.go('/list'); // 저장 후 리스트로 이동
      }
    } catch (e) {
      if (mounted) {
        await showSaveErrorDialog(context);
      }
    }

    return returnRow;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(),
      body: PageWrapper(
        child: Column(
          children: [
            // 공백 포함 여부 토글 + 저장 버튼 영역
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: screenWidth * 0.03), // 들여쓰기
                const Text(
                  '공백 포함',
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                Switch(
                  value: _includeSpaces,
                  onChanged: (value) {
                    setState(() {
                      _includeSpaces = value;
                    });
                  },
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _saveText,
                  style: ElevatedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF7E57C2), width: 2.0),
                    backgroundColor: const Color(0xFF7E57C2),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    '저장',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 제목 입력 텍스트필드
            SizedBox(
              width: screenWidth * 0.9,
              child: TextField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: "제목을 입력하세요.",
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontWeight: FontWeight.normal,
                    height: 1.5,
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 내용 입력 텍스트필드 (확장, 고정 높이)
            SizedBox(
              height: screenHeight * 0.5,
              width: screenWidth * 0.9,
              child: TextField(
                controller: _contentController,
                onChanged: (text) => setState(() {}),
                minLines: null,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: "내용을 입력하세요.",
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontWeight: FontWeight.normal,
                    height: 1.5,
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 현재 글자 수 표시 (색상은 유효/무효에 따라 다름)
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 18, color: Colors.black),
                children: [
                  const TextSpan(text: '글자 수: '),
                  TextSpan(
                    text: '${_getCharCount()}자',
                    style: TextStyle(
                      color: _getCountColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}