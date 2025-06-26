import 'package:flutter/material.dart';
import 'package:txt2000/database/db_helper.dart';
import 'package:txt2000/models/text_model.dart';
import '../widgets/common_page_wrapper.dart';
import 'list_page.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final DBHelper _dbHelper = DBHelper();

  late final int _seq;
  TextModel? _textData;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _seq = args['seq'];
    _loadText(_seq);
  }

  Future<void> _loadText(int seq) async {
    final result = await _dbHelper.getTextBySeq(seq);

    if (!mounted) return;

    setState(() {
      _textData = result;
      _isLoading = false;
    });
  }

  void _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('정말 삭제할까요?'),
        content: Text('삭제한 글은 복구할 수 없어요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _dbHelper.deleteText(_textData!.seq!); // 모델 아직 안 써서 Map 기준
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => ListPage()),
        ModalRoute.withName('/home'),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _textData == null
          ? Center(child: Text('글을 찾을 수 없습니다.'))
          : PageWrapper(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _textData!.title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        if (_textData == null) return;
                        Navigator.pushReplacementNamed(
                          context,
                          '/write',
                          arguments: {
                            'mode': 'edit',
                            'text': _textData,
                          },
                        );
                      },
                      icon: Icon(Icons.edit_outlined, color: Colors.blue),
                      label: Text('수정', style: TextStyle(color: Colors.blue)),
                    ),
                    SizedBox(width: 4),
                    TextButton.icon(
                      onPressed: () => _confirmDelete(context),
                      icon: Icon(Icons.delete_outline, color: Colors.red),
                      label: Text('삭제', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),


                Text(
                  _textData!.content,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
    );
  }
}
