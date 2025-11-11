import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:food_recomm/style.dart';
import 'package:food_recomm/UploadPage.dart';
import 'package:food_recomm/RecommendDialog.dart';
import 'package:food_recomm/MyPage.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_time_patterns.dart';

class MyApp extends StatefulWidget { // 메인 함수
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  var data = [];
  DateTime date = DateTime.now();

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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( // 메인페이지 상단
        backgroundColor: Colors.lightGreen,
        title: Text('Prototype'),
        actions: [
          IconButton(onPressed: _pickDate, icon: Icon(Icons.calendar_today)), // 달력 버튼
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> const MyPage()),);
          }, icon: Icon(Icons.person)), // 사용자 버튼
        ],
      ),
      body: Home(date: date),
    );
  }
}

class Home extends StatefulWidget { // 메인페이지 중단
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
          child: Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [Container(height: 200, width: 150,
              decoration: BoxDecoration(color: Colors.white54, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10),offset: const Offset(0, 8),blurRadius: 16,spreadRadius: 0)]),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('칼로리',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.center,children: [
                  Text('1000',style: TextStyle(fontSize: 16)), // 데이터 받아오는걸로 수정 필요
                  Text('Kcal',style: TextStyle(fontSize: 16)),
                ],)
              ],),
            ),
              SizedBox(width: 10), // 컨테이너 사이 여백
              Container(height: 200, width: 150,
                  decoration: BoxDecoration( color:Colors.white54,borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10),offset: const Offset(0, 8),blurRadius: 16,spreadRadius: 0)]),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('탄수화물:', style: TextStyle(fontSize: 16)),
                      SizedBox(height: 4),
                      Text('단백질:', style: TextStyle(fontSize: 16)),
                      SizedBox(height: 4),
                      Text('지방:', style: TextStyle(fontSize: 16)),
                    ],),
                    Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [SizedBox(width: 5,)],),
                    Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(child: Text('250', style: TextStyle(fontSize: 16))), // 데이터 받아오는걸로 수정 필요
                      SizedBox(height: 4),
                      Container(child: Text('250', style: TextStyle(fontSize: 16))), // 데이터 받아오는걸로 수정 필요
                      SizedBox(height: 4),
                      Container(child: Text('250', style: TextStyle(fontSize: 16))), // 데이터 받아오는걸로 수정 필요
                    ],),
                    Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(child: Text(' g', style: TextStyle(fontSize: 16))),
                      SizedBox(height: 4),
                      Container(child: Text(' g', style: TextStyle(fontSize: 16))),
                      SizedBox(height: 4),
                      Container(child: Text(' g', style: TextStyle(fontSize: 16))),
                    ],)
                  ],)
              )
            ],),),
        SizedBox(height: 8), // 간격
        Text('오늘의 식사', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
        MealCard(title: '아침', color: Colors.red), // 아침 카드
        MealCard(title: '점심', color: Colors.lightGreen), // 점심 카드
        MealCard(title: '저녁', color: Colors.lightBlue), // 저녁 카드
        Container(decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20),), // 식단 추천 버튼
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 12),
          height: 50,
          child: TextButton(onPressed: (){showDialog(context: context, builder: (BuildContext context){return const RecommendDialog();},);}, child: Text('AI 식단 추천받기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
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



class MealCard extends StatelessWidget { // 아침,점심,저녁 카드
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
              IconButton(onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const UploadPage(userImage: null),),);},// 이미지 없으면 null
                icon: const Icon(Icons.add_circle, color: Colors.green),
              )
            ],),
          ],),
      ),
    );
  }
}

class EatData extends StatelessWidget { // 카드별 세부정보 보기
  const EatData({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(width: 300, height: 300,
          child: Column( mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Food data'), // 요청받아 음식명, 00g 형태로 여러개 받아올 예정. 삭제 기능 추가 필요
              TextButton(onPressed: (){ Navigator.pop(context); }, child: Text('Exit'))
            ],)),
    );}
}

