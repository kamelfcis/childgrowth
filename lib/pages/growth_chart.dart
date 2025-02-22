import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GrowthChart extends StatefulWidget {
  @override
  _GrowthChartState createState() => _GrowthChartState();
}

class _GrowthChartState extends State<GrowthChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  List<FlSpot> chartData = [
    FlSpot(1, 50),
    FlSpot(2, 55),
    FlSpot(3, 60),
    FlSpot(4, 65),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: 300,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
            gradient: LinearGradient(colors: [Colors.blue.shade100, Colors.blue.shade300]),
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, interval: 5),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, interval: 1),
                ),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: chartData.map((spot) {
                    return FlSpot(spot.x, spot.y * _animation.value);
                  }).toList(),
                  isCurved: true,
                  color: Colors.blue.shade800,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade300.withOpacity(0.5), Colors.blue.shade100.withOpacity(0)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
