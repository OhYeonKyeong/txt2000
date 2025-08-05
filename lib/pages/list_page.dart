import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:txt2000/database/db_helper.dart';
import 'package:txt2000/models/text_model.dart';
import '../widgets/common_page_wrapper.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  ListPageState createState() => ListPageState();
}

class ListPageState extends State<ListPage> with WidgetsBindingObserver {
  final DBHelper _dbHelper = DBHelper();
  late Future<List<TextModel>> _futureTexts;

  @override
  void initState() {
    super.initState();
    _futureTexts = _dbHelper.getTextsList();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // 앱이 다시 활성화될 때 데이터 리로드
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _reloadTexts();
    }
  }

  // 데이터 새로고침
  void _reloadTexts() {
    setState(() {
      _futureTexts = _dbHelper.getTextsList();
    });
  }

  // 글 생성일 포맷
  String _formatDate(String isoDate) {
    try {
      final parsed = DateTime.parse(isoDate);
      return DateFormat('MM/dd').format(parsed);
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _reloadTexts();
        }
      },
      child: Scaffold(
        appBar: AppBar(),
        body: FutureBuilder<List<TextModel>>(
          future: _futureTexts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
            } else {
              final texts = snapshot.data ?? [];
              if (texts.isEmpty) {
                return const Center(child: Text('저장된 글이 없습니다.'));
              }

              return ListView.builder(
                itemCount: texts.length,
                itemBuilder: (context, index) {
                  final item = texts[index];
                  return PageWrapper(
                    child: ListTile(
                      title: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _formatDate(item.createdAt),
                              style: const TextStyle(fontSize: 16, color: Colors.black87),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.title.isNotEmpty ? item.title : '제목 없음',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        item.content.length > 20
                            ? '${item.content.substring(0, 20)}...'
                            : item.content,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      onTap: () {
                        context.push('/detail/${item.seq}').then((_) => _reloadTexts());
                      },
                    ),
                  );
                },
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.push('/write').then((_) => _reloadTexts());
          },
          child: const Icon(Icons.add),
          tooltip: '새 글 작성하기',
        ),
      ),
    );
  }
}