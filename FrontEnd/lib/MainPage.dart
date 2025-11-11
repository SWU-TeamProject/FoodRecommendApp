import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'package:food_recomm/UploadPage.dart';
import 'package:food_recomm/RecommendDialog.dart';
import 'package:food_recomm/MyPage.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_time_patterns.dart';

class MyApp extends StatefulWidget { // 메인 함수
  const MyApp({super.key, this.uid});
  final int? uid;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // 날짜 상태
  DateTime date = DateTime.now();

  // 요약 데이터 상태
  double? calorie;
  double? carbohydrate;
  double? protein;
  double? fat;

  bool _loading = false;
  String? _error;

  // 서버 베이스 URL (필요에 따라 수정)
  static const String _baseUrl = 'http://localhost:8080';

  @override
  void initState() {
    super.initState();
    _loadSummary(); // 앱 시작 시 현재 날짜로 로드
  }

  Future<void> _loadSummary() async {
    // uid가 없으면 요청 생략
    if (widget.uid == null) {
      setState(() {
        _error = '로그인 정보(uid)가 없어 요약을 불러올 수 없습니다.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    final dio = Dio();
    final String ymd = DateFormat('yyyy-MM-dd').format(date);
    try {
      final res = await dio.get(
        '$_baseUrl/api/diet/${widget.uid}/summary',
        queryParameters: {'date': ymd},
      );

      print(res.data);
      final data = res.data as Map<String, dynamic>;
      final newCalorie = data['kacl']?.toDouble();
      final newCarb = data['carbohydrate']?.toDouble();
      final newProtein = data['protein']?.toDouble();
      final newFat = data['fat']?.toDouble();
      setState(() {
        calorie = newCalorie;
        carbohydrate = newCarb;
        protein = newProtein;
        fat = newFat;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = '요약 불러오기 실패: $e';
      });
      // 화면 하단 스낵바로도 알림
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('요약 불러오기 실패: $e')),
        );
      }
    }
  }

  Future<void> _pickDate() async { // 날짜 선택 함수
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('ko', 'KR'), // 한글 달력
    );
    if (picked != null && picked != date) {
      setState(() {
        date = picked;
      });
      // 날짜 바뀌면 즉시 재요청
      await _loadSummary();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( // 메인페이지 상단
        backgroundColor: Colors.lightGreen,
        title: const Text('Prototype'),
        actions: [
          IconButton(onPressed: _pickDate, icon: const Icon(Icons.calendar_today)), // 달력 버튼
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MyPage(uid: widget.uid)));
            },
            icon: const Icon(Icons.person),
          ), // 사용자 버튼
        ],
      ),
      body: Home(
        uid: widget.uid,
        date: date,
        loading: _loading,
        error: _error,
        calorie: calorie,
        carbohydrate: carbohydrate,
        protein: protein,
        fat: fat,
      ),
    );
  }
}

class Home extends StatefulWidget { // 메인페이지 중단
  const Home({
    super.key,
    this.uid,
    this.date,
    this.loading = false,
    this.error,
    this.calorie,
    this.carbohydrate,
    this.protein,
    this.fat,
  });

  final int? uid;
  final DateTime? date;
  final bool loading;
  final String? error;
  final double? calorie;
  final double? carbohydrate;
  final double? protein;
  final double? fat;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _fmtNum(double? v, {int decimals = 0}) {
    if (v == null) return '--';
    final fixed = v.toStringAsFixed(decimals);
    return fixed;
  }

  @override
  Widget build(BuildContext context) {
    final theDate = widget.date ?? DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(DateFormat('yyyy-MM-dd').format(theDate), style: const TextStyle(fontSize: 30)),

        // 로딩/에러 상태 표시
        if (widget.loading)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: CircularProgressIndicator(),
          ),
        if (!widget.loading && widget.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              widget.error!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),

        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          height: 150,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 칼로리 카드
              Container(
                height: 200,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.white54,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      offset: const Offset(0, 8),
                      blurRadius: 16,
                      spreadRadius: 0,
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('칼로리', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_fmtNum(widget.calorie, decimals: 0), style: const TextStyle(fontSize: 16)),
                        const Text(' Kcal', style: TextStyle(fontSize: 16)),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(width: 10), // 컨테이너 사이 여백

              // 탄/단/지 카드
              Container(
                height: 200,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.white54,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      offset: const Offset(0, 8),
                      blurRadius: 16,
                      spreadRadius: 0,
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('탄수화물:', style: TextStyle(fontSize: 16)),
                        SizedBox(height: 4),
                        Text('단백질:', style: TextStyle(fontSize: 16)),
                        SizedBox(height: 4),
                        Text('지방:', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: const [SizedBox(width: 5)]),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_fmtNum(widget.carbohydrate, decimals: 0), style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(_fmtNum(widget.protein, decimals: 0), style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(_fmtNum(widget.fat, decimals: 0), style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(' g', style: TextStyle(fontSize: 16)),
                        SizedBox(height: 4),
                        Text(' g', style: TextStyle(fontSize: 16)),
                        SizedBox(height: 4),
                        Text(' g', style: TextStyle(fontSize: 16)),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 8), // 간격
        const Text('오늘의 식사', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        MealCard(title: '아침', color: Colors.red, uid: widget.uid), // 아침 카드
        MealCard(title: '점심', color: Colors.lightGreen, uid: widget.uid), // 점심 카드
        MealCard(title: '저녁', color: Colors.lightBlue, uid: widget.uid), // 저녁 카드
        Container(
          decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)), // 식단 추천 버튼
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          height: 50,
          child: TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return RecommendDialog(uid: widget.uid);
                },
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.black, // 텍스트 색상
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: const Text('AI 식단 추천받기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ],
    );
  }
}

class MealCard extends StatelessWidget { // 아침,점심,저녁 카드
  const MealCard({super.key, required this.title, required this.color, this.uid});
  final String title;
  final Color color;
  final int? uid;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    showDialog(context: context, builder: (context) => EatData(uid: uid));
                  },
                  icon: const Icon(Icons.keyboard_arrow_down),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => UploadPage(uid: uid, userImage: null)),
                    );
                  }, // 이미지 없으면 null
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EatData extends StatelessWidget { // 카드별 세부정보 보기
  const EatData({super.key, this.uid});
  final int? uid;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 300,
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Food data'), // 요청받아 음식명, 00g 형태로 여러개 받아올 예정. 삭제 기능 추가 필요
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Exit')),
          ],
        ),
      ),
    );
  }
}


