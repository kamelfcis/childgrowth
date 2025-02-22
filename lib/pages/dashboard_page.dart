import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool isLoading = true;
  int recordCount = 0;
  List<double> bmiValues = [];
  List<double> weightValues = [];
  List<String> dates = [];

  @override
  void initState() {
    super.initState();
    _fetchGrowthRecords();
  }

 Future<void> _fetchGrowthRecords() async {
  print("Fetching records from Supabase...");
  try {
    final response = await Supabase.instance.client
        .from('growth_records')
        .select()
        .order('recorded_at', ascending: true);

    print("Response from Supabase: $response"); // 🔴 Debugging output

    if (response == null || response.isEmpty) {
      print("No records found.");
      setState(() {
        isLoading = false;
      });
      return;
    }

    setState(() {
      recordCount = response.length;
      bmiValues = response.map<double>((r) => (r['bmi'] as num?)?.toDouble() ?? 0.0).toList();
      weightValues = response.map<double>((r) => (r['weight_kg'] as num?)?.toDouble() ?? 0.0).toList();
      dates = response.map<String>((r) => (r['recorded_at'] ?? "").toString().split('T')[0]).toList();
      isLoading = false;
    });

  } catch (error) {
    print("Error fetching records: $error"); // 🔴 Debugging error
    setState(() => isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.dashboard, color: Colors.white),
            SizedBox(width: 10),
            Text(
              "Dashboard",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 19, 7, 73),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Total Records Counter
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 19, 7, 73),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
                    ),
                    child: Text(
                      "📊 Total Growth Records: $recordCount",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 20),

                  // BMI Trend Line Chart
                  if (bmiValues.isNotEmpty)
                    Container(
                      height: 250,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                      ),
                      child: Column(
                        children: [
                          Text(
                            "📈 BMI Over Time",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Expanded(child: _buildLineChart()),
                        ],
                      ),
                    ),

                  SizedBox(height: 20),

                  // Weight Distribution Bar Chart
                  if (weightValues.isNotEmpty)
                    Container(
                      height: 250,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                      ),
                      child: Column(
                        children: [
                          Text(
                            "🏋️ Weight Distribution",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Expanded(child: _buildBarChart()),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  /// ✅ **Fixed: Correctly Wrap LineChartData inside LineChart Widget**
 Widget _buildLineChart() {
  return LineChart(
    LineChartData(
      gridData: FlGridData(show: true),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (double value, TitleMeta meta) {
              int index = value.toInt();
              if (index >= 0 && index < dates.length) {
                return Text(dates[index], style: TextStyle(fontSize: 10));
              }
              return Text('');
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: true),
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(
            bmiValues.length,
            (index) => FlSpot(index.toDouble(), bmiValues[index]),
          ),
          isCurved: true,
          barWidth: 3,
          color: Colors.blueAccent,
          dotData: FlDotData(show: true),
        ),
      ],
    ),
  );
}


  /// ✅ **Fixed: Correctly Wrap BarChartData inside BarChart Widget**
  Widget _buildBarChart() {
  return BarChart(
    BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: weightValues.isNotEmpty ? weightValues.reduce((a, b) => a > b ? a : b) + 5 : 10,
      barGroups: List.generate(
        weightValues.length,
        (index) => BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: weightValues[index],
              color: Colors.greenAccent,
              width: 16,
            ),
          ],
        ),
      ),
    ),
  );
}

}
