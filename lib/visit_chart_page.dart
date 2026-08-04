import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class VisitChartPage extends StatelessWidget {
  const VisitChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('방문 추세'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '최근 7일 방문 수',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // 그래프가 표시될 영역
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 30,

                  // 배경 격자
                  gridData: const FlGridData(
                    show: true,
                  ),

                  // 그래프 테두리
                  borderData: FlBorderData(
                    show: true,
                  ),

                  // 축 제목
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: _bottomTitle,
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 5,
                      ),
                    ),
                  ),

                  // 실제 선 그래프 데이터
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 5),
                        FlSpot(1, 8),
                        FlSpot(2, 7),
                        FlSpot(3, 15),
                        FlSpot(4, 18),
                        FlSpot(5, 22),
                        FlSpot(6, 27),
                      ],
                      isCurved: true,
                      barWidth: 4,
                      dotData: const FlDotData(
                        show: true,
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _bottomTitle(double value, TitleMeta meta) {
    const days = [
      '월',
      '화',
      '수',
      '목',
      '금',
      '토',
      '일',
    ];

    final index = value.toInt();

    if (index < 0 || index >= days.length) {
      return const SizedBox.shrink();
    }

    return SideTitleWidget(
      meta: meta,
      child: Text(days[index]),
    );
  }
}