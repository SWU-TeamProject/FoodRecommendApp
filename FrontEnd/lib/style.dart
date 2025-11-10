import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

var MyTheme = ThemeData(
);

class nutrient_chart extends StatefulWidget {
  final max_protein;
  final max_carbonhy;
  final max_fat;

  final protein;
  final carbonhy;
  final fat;
  const nutrient_chart({super.key, this.max_protein, this.max_carbonhy, this.max_fat, this.protein, this.carbonhy, this.fat});

  @override
  State<nutrient_chart> createState() => _nutrient_chartState();
}
class _nutrient_chartState extends State<nutrient_chart> {
  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        titlesData: FlTitlesData( show: false,
        ),
        barGroups: [// toY 까지 그래프 표기
          BarChartGroupData(x: 0,barRods: [BarChartRodData(toY: widget.max_protein,
              backDrawRodData: BackgroundBarChartRodData(show: true, toY: widget.max_protein, color: Colors.grey[300]))]),
          BarChartGroupData(x: 1,barRods: [BarChartRodData(toY: widget.max_carbonhy,
              backDrawRodData: BackgroundBarChartRodData(show: true, toY: widget.max_carbonhy, color: Colors.grey[300]))]),
          BarChartGroupData(x: 2,barRods: [BarChartRodData(toY: widget.max_fat,
              backDrawRodData: BackgroundBarChartRodData(show: true, toY: widget.max_fat, color: Colors.grey[300]))]),
        ]
      )
    );
  }
}

///////////////////////////////////////////////////////////////
class ProteinBarChart extends StatelessWidget {
  final double todayProtein; // 오늘 먹은 단백질
  final double goalProtein;  // 목표 단백질

  const ProteinBarChart({
    super.key,
    required this.todayProtein,
    required this.goalProtein,
  });

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        rotationQuarterTurns: 1, // 90도 회전
        alignment: BarChartAlignment.center, // 중앙 정렬
        maxY: goalProtein, // 최대값
        minY: 0, // 최소값
        barTouchData: BarTouchData(enabled: false), // 터치 미지원
        titlesData: FlTitlesData(
          leftTitles:  AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,

          )),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: todayProtein,     // 오늘 먹은 단백질 수치까지 차트 표시!
                color: Colors.green,   // 색상
                width: 30,             // 막대 두께
                borderRadius: BorderRadius.circular(8),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: goalProtein,   // 배경 막대(전체 목표)
                  color: Colors.grey[300],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}