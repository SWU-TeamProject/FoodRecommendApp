import 'package:flutter/material.dart';
import 'package:intl/date_time_patterns.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:food_recomm/style.dart';

void main() {
  runApp(MaterialApp(
    theme: MyTheme,
    home: MyApp(),
    locale: const Locale('ko','KR'), // 한국어 지역, 언어 설정
    supportedLocales: const [ // 한국어, 영어 지원
      Locale('en', 'US'),
      Locale('ko', 'KR'),
    ],
    localizationsDelegates: const [ // 위젯 번역
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  var data = [];
  DateTime date = DateTime.now();
  /// ⬇️ 날짜 선택 함수
  Future<void> _pickDate() async {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: Text('Prototype'),
        actions: [
          IconButton(onPressed: _pickDate, icon: Icon(Icons.calendar_today)), // 달력 버튼
          IconButton(onPressed: (){}, icon: Icon(Icons.person)), // 사용자 버튼
        ],
      ),
      body: Home(date: date),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key, this.date});
  final date;

  @override
  State<Home> createState() => _HomeState();
}
class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Column( crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(DateFormat('yyyy-MM-dd').format(widget.date), style: TextStyle(fontSize: 30)),
        Container(width: double.infinity, margin: EdgeInsets.symmetric(horizontal: 12), height: 150, padding: EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration( borderRadius: BorderRadius.circular(24),),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Container(height: 300, width: 300, child: ProteinBarChart(todayProtein: 50, goalProtein: 100)),Container(child: Text('[원형그래프]'),)],),),
        Text('오늘의 식사', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
        MealCard(title: '아침', color: Colors.red), // 아침 카드
        MealCard(title: '점심', color: Colors.lightGreen), // 점심 카드
        MealCard(title: '저녁', color: Colors.lightBlue), // 저녁 카드
        Container(decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20),), // 식단 추천 버튼
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 12),
          height: 50,
          child: TextButton(onPressed: (){}, child: Text('AI 식단 추천받기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,  // 텍스트 색상
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24),)
              )),
        ),
      ],
    );
  }
}



class MealCard extends StatelessWidget {
  const MealCard({super.key, required this.title, required this.color,});
  final String title;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin:  EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding:  EdgeInsets.symmetric(vertical: 18, horizontal: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16,),),
            Row(children: [
                IconButton( onPressed: (){showDialog(context: context, builder: (context){return EatData();});}, icon: Icon(Icons.keyboard_arrow_down)),
                SizedBox(width: 8),
                IconButton(onPressed: (){EatData();}, icon: Icon(Icons.add_circle, color: Colors.green)),
              ],),
          ],),
      ),
    );
  }
}

class EatData extends StatelessWidget {
  const EatData({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(width: 300, height: 300,
      child: Column( mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Food data'),
          TextButton(onPressed: (){ Navigator.pop(context); }, child: Text('Exit'))
        ],)),
    );}
}


