import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:txt2000/database/db_helper.dart';
import '../models/text_model.dart';
import '../widgets/common_page_wrapper.dart';

class WritePage extends StatefulWidget {
  const WritePage({super.key});

  @override
  _WritePageState createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {

  // DB인스턴스
  final DBHelper _dbHelper = DBHelper();

  // 텍스트 변수들
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _includeSpaces = true;

  // 글자 수 제한 관련 변수들
  int _baseCharCount = 20;
  double _tolerance = 0.1;
  int get minTxt => (_baseCharCount * (1 - _tolerance)).round();
  int get maxTxt => (_baseCharCount * (1 + _tolerance)).round();

  // 글 수정 관련 변수들
  bool _isEditMode = false;
  TextModel? _textData;

  // 수정으로 진입한 경우 파라미터 처리
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is Map && args['mode'] == 'edit') {
      _isEditMode = true;
      _textData = args['text'];

      print('데이터 : ');
      print(_textData!);

      _titleController.text = _textData?.title ?? '';
      _contentController.text = _textData?.content ?? '';
    }
  }

  // 공백 포함 여부에 따라 글자 수 계산 (비공개)
  int _getCharCount() {
    if (_includeSpaces) {
      return _contentController.text.length;
    } else {
      return _contentController.text.replaceAll(RegExp(r'\s+'), '').length;
    }
  }

  // 글자 수에 따른 색상 반환 (비공개)
  Color _getCountColor() {
    int count = _getCharCount();
    if (count >= minTxt && count <= maxTxt) {
      return const Color(0xFF81C784); // 초록 (유효)
    } else {
      return const Color(0xFFE57373); // 빨강 (무효)
    }
  }

  // 저장 가능 여부 확인 (비공개)
  bool _isCharCountValid() {
    int count = _getCharCount();
    return count >= minTxt && count <= maxTxt;
  }

  // 저장 기능 (비공개)
  Future<int> _saveText(String savedText) async {
    String _saveTitle = _titleController.text.trim();
    String _saveContent = _contentController.text.trim();

    if (_saveTitle.isEmpty) {
      // 제목 없으면 오늘 날짜로 기본 셋팅
      final now = DateTime.now();
      _saveTitle = DateFormat('yyyy-MM-dd').format(now) + '에 쓴 글';
    }

    final now = DateTime.now().toIso8601String();
    int returnRow = -1;

    try {
      if(_isEditMode) {
        // 수정
        final updated = TextModel(
          seq: _textData!.seq,
          title: _saveTitle,
          content: _saveContent,
          createdAt: _textData!.createdAt, // 기존 생성일 유지
          modifiedAt: now,
        );

        setState(() {
          _textData = updated;
        });

        returnRow = await _dbHelper.updateText(updated);

      } else {
        // 신규 생성
        final newText = TextModel(
          title: _saveTitle,
          content: _saveContent,
          createdAt: now,
          modifiedAt: now,
        );

        returnRow = await _dbHelper.insertText(newText);
      }

    } catch (e) {
      // 실패 시 예외 처리
      print('저장 실패: $e');
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: Text('저장 중 오류가 발생했습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('확인'),
            ),
          ],
        ),
      );
    }

    return returnRow;
  }

  // 메시지 기능
  Future<void> _showErrorDialog() async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text('저장에 실패했습니다.\n조건을 확인해주세요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text('저장된 글 목록'),
      ),
      body: PageWrapper(
        child: Column(
          children: [
            // 공백 포함 라벨 + 스위치 행
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: MediaQuery.of(context).size.width * 0.03), // 반응형 약간 들여쓰기
                Text(
                  '공백 포함',
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 10),
                Switch(
                  value: _includeSpaces,
                  onChanged: (value) {
                    setState(() {
                      _includeSpaces = value;
                    });
                  },
                ),

                Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    if (_isCharCountValid()) {
                      String _saveTitle = _titleController.text.trim();
                      String _saveContent = _contentController.text.trim();

                      if (_saveTitle.isEmpty) {
                        final now = DateTime.now();
                        _saveTitle = DateFormat('yyyy-MM-dd').format(now) + '에 쓴 글';
                      }

                      final now = DateTime.now().toIso8601String();
                      int returnRow = -1;
                      int? newSeq;

                      try {
                        if (_isEditMode) {
                          final updated = TextModel(
                            seq: _textData!.seq,
                            title: _saveTitle,
                            content: _saveContent,
                            createdAt: _textData!.createdAt,
                            modifiedAt: now,
                          );
                          returnRow = await _dbHelper.updateText(updated);
                          newSeq = updated.seq;
                        } else {
                          final created = TextModel(
                            title: _saveTitle,
                            content: _saveContent,
                            createdAt: now,
                            modifiedAt: now,
                          );
                          returnRow = await _dbHelper.insertText(created);
                          newSeq = returnRow;
                        }

                        if (returnRow > 0 && newSeq != null) {
                          Navigator.pushReplacementNamed(
                            context,
                            '/detail',
                            arguments: {'seq': newSeq},
                          );
                        } else {
                          // 실패 시 → 현재 화면 유지 + Alert
                          await _showErrorDialog();
                        }
                      } catch (e) {
                        print('저장 실패: $e');
                        await _showErrorDialog();
                      }
                    } else {
                      await _showErrorDialog();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    side: BorderSide(color: Color(0xFF7E57C2), width: 2.0),
                    backgroundColor: Color(0xFF7E57C2),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    '저장',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,  // 너비 90% 고정
              child: TextField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "제목을 입력하세요.",
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontWeight: FontWeight.normal,
                    height: 1.5,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                ),
              ),
            ),

            SizedBox(height: 10),

            // 텍스트 입력창 (고정 높이, 반응형 너비)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5, // 전체 화면 높이의 60% 고정
              width: MediaQuery.of(context).size.width * 0.9,   // 너비도 90% 고정
              child: TextField(
                controller: _contentController,
                onChanged: (text) {
                  setState(() {
                  });
                },
                minLines: null,
                maxLines: null,
                expands: true, // TextField가 SizedBox 크기만큼 꽉 채우게 함
                textAlignVertical: TextAlignVertical.top,  // 힌트 텍스트 세로 위쪽 정렬
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "내용을 입력하세요.",
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontWeight: FontWeight.normal,
                    // 텍스트가 위쪽에 붙도록
                    height: 1.5,
                  ),
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                ),
              ),
            ),

            SizedBox(height: 20),

            // 글자 수 표시
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 18, color: Colors.black),
                children: [
                  TextSpan(text: '글자 수: '),
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
