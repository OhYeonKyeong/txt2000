import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:txt2000/database/db_helper.dart';
import 'package:txt2000/models/text_model.dart';
import '../widgets/common_page_wrapper.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  ListPageState createState() => ListPageState();
}

class ListPageState extends State<ListPage> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadTexts();  // 리스트 페이지가 다시 보여질 때 호출
  }


  final DBHelper _dbHelper = DBHelper();

  List<TextModel> _texts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTexts();
  }

  // DB에서 데이터 불러오기
  Future<void> _loadTexts() async {
    final data = await _dbHelper.getTextsList(); // DBHelper에서 목록을 가져오는 함수 필요

    // Failed assertion: line 6179 pos 14: '_dependents.isEmpty': is not true. 방지
    if (!mounted) return;

    setState(() {
      _texts = data;
      _isLoading = false;
    });
  }


  // 제목 옆에 표시될 글 생성일
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
    return Scaffold(
      appBar: AppBar(
        // title: Text('저장된 글 목록'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // 데이터 로딩중
          : _texts.isEmpty
          ? Center(child: Text('저장된 글이 없습니다.')) // 저장된 글이 없음
          : ListView.builder( // 저장된 글이 있음
            itemCount: _texts.length,
            itemBuilder: (context, index) {
              final item = _texts[index];
              return PageWrapper(
                  child: ListTile(
                    title: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _formatDate(item.createdAt),
                            style: TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ),
                        SizedBox(width: 8), // 날짜와 제목 사이 간격
                        Expanded(
                          child: Text(
                            item.title ?? '제목 없음',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

                    // 글 상세보기로 넘어가기
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/detail',
                        arguments: {'seq': item.seq},
                      );
                    },
                  )
              );
            },
          ),
    );
  }
}
