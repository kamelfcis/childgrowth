import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> childrenList = [];

  @override
  void initState() {
    super.initState();
    _fetchChildren();
  }

  Future<void> _fetchChildren() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final response = await Supabase.instance.client
        .from('children')
        .select()
        .eq('parent_id', user.id)
        .order('dob', ascending: true);

    setState(() {
      childrenList = List<Map<String, dynamic>>.from(response);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.bar_chart, color: Colors.white),
            SizedBox(width: 10),
            Text(
              "Growth Statistics",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 26, 2, 67),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : childrenList.isEmpty
              ? Center(child: Text("No children found. Add a child first!"))
              : DefaultTabController(
                  length: childrenList.length,
                  child: Column(
                    children: [
                      Container(
                        color: const Color.fromARGB(255, 169, 139, 226),
                        child: TabBar(
                          isScrollable: true,
                          labelColor: Colors.white,
                          unselectedLabelColor: const Color.fromARGB(255, 37, 5, 92),
                          indicatorColor: Colors.white,
                          tabs: childrenList.map((child) {
                            return Tab(text: child['full_name']);
                          }).toList(),
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: childrenList.map((child) {
                            return ChildStatisticsTab(childId: child['id']);
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class ChildStatisticsTab extends StatefulWidget {
  final String childId;
  ChildStatisticsTab({required this.childId});

  @override
  _ChildStatisticsTabState createState() => _ChildStatisticsTabState();
}

class _ChildStatisticsTabState extends State<ChildStatisticsTab> {
  bool isLoading = true;
  int recordCount = 0;
  List<double> bmiValues = [];
  List<double> weightValues = [];
  List<double> heightValues = [];
  List<double> headCircumferenceValues = [];
  List<String> dates = [];

  @override
  void initState() {
    super.initState();
    _fetchGrowthRecords();
  }

  Future<void> _fetchGrowthRecords() async {
    try {
      final response = await Supabase.instance.client
          .from('growth_records')
          .select()
          .eq('child_id', widget.childId)
          .order('recorded_at', ascending: true);

      if (response.isEmpty) {
        setState(() => isLoading = false);
        return;
      }

      setState(() {
        recordCount = response.length;
        bmiValues = response.map<double>((r) => (r['bmi'] as num?)?.toDouble() ?? 0.0).toList();
        weightValues = response.map<double>((r) => (r['weight_kg'] as num?)?.toDouble() ?? 0.0).toList();
        heightValues = response.map<double>((r) => (r['height_cm'] as num?)?.toDouble() ?? 0.0).toList();
        headCircumferenceValues = response.map<double>((r) => (r['head_cm'] as num?)?.toDouble() ?? 0.0).toList();
        dates = response.map<String>((r) => (r['recorded_at'] ?? "").toString().split('T')[0]).toList();
        isLoading = false;
      });
    } catch (error) {
      print("Error fetching records: $error");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 3, 94, 50),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
                  ),
                  child: Text(
                    "📊 Who Growth Charts: $recordCount",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 20),

                Expanded(
                  child: ListView(
                    children: [
                      _buildChart("📈 BMI Over Time", bmiValues, Colors.blue, "BMI"),
                      _buildChart("📏 Height Over Time", heightValues, Colors.orange, "Height (cm)"),
                      _buildChart("🏋️ Weight Over Time", weightValues, Colors.green, "Weight (kg)"),
                      _buildChart("👶 Head Circumference", headCircumferenceValues, Colors.red, "Head (cm)"),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  /// 📊 **Reusable Method to Build Charts**
  Widget _buildChart(String title, List<double> values, Color color, String label) {
    return values.isEmpty
        ? Center(child: Text("No records available for $label", style: TextStyle(fontSize: 16, color: Colors.grey)))
        : Container(
            height: 250,
            margin: EdgeInsets.symmetric(vertical: 10),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
            ),
            child: Column(
              children: [
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, reservedSize: 35),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
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
                            values.length,
                            (index) => FlSpot(index.toDouble(), values[index]),
                          ),
                          isCurved: true,
                          barWidth: 3,
                          color: color,
                          dotData: FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
