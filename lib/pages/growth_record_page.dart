import 'package:child_growth_tracker/pages/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/growth_utils.dart';

class GrowthRecordPage extends StatefulWidget {
  final String childId;

  GrowthRecordPage({required this.childId});

  @override
  _GrowthRecordPageState createState() => _GrowthRecordPageState();
}

class _GrowthRecordPageState extends State<GrowthRecordPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();

  bool isLoading = false;
  bool isChecked = false;
  double bmi = 0;
  double zScore = 0;
  String status = "";
  List<Map<String, dynamic>> growthRecords = [];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();
    _fetchGrowthRecords();
    _initNotifications();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _sendNotification(String message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'growth_alerts',
      'Growth Alerts',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      0,
      '📢 Growth Record Saved!',
      message,
      platformDetails,
    );
  }

  Future<void> _fetchGrowthRecords() async {
    final response = await Supabase.instance.client
        .from('growth_records')
        .select()
        .eq('child_id', widget.childId)
        .order('recorded_at', ascending: false);

    setState(() {
      growthRecords = List<Map<String, dynamic>>.from(response);
    });
  }

  void checkGrowthCalculation() {
    if (weightController.text.isEmpty || heightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter weight and height.")),
      );
      return;
    }

    setState(() => isLoading = true);

    Future.delayed(Duration(seconds: 1), () {
      double weight = double.parse(weightController.text);
      double height = double.parse(heightController.text);

      bmi = calculateBMI(weight, height);
      double meanWeight = 22.0;
      double stdWeight = 2.0;
      zScore = calculateZScore(weight, meanWeight, stdWeight);
      status = checkGrowthStatus(weight, height, meanWeight, stdWeight);

      setState(() {
        isChecked = true;
        isLoading = false;
      });
    });
  }

  void saveGrowthRecord() async {
    if (!isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please check calculations first!")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await Supabase.instance.client.from('growth_records').insert({
        'child_id': widget.childId,
        'height_cm': double.parse(heightController.text),
        'weight_kg': double.parse(weightController.text),
        // 'bmi': bmi,
        'z_score': zScore,
        'growth_status': status,
        'recorded_at': DateTime.now().toIso8601String(),
      });

      _sendNotification("Growth record added successfully! 🎉");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Growth record saved!"),
            backgroundColor: Colors.green),
      );

      weightController.clear();
      heightController.clear();
      isChecked = false;
      _fetchGrowthRecords();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error saving record: ${error.toString()}"),
            backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void deleteRecord(String recordId) async {
    await Supabase.instance.client
        .from('growth_records')
        .delete()
        .eq('id', recordId);
    _fetchGrowthRecords();
  }

  Widget _headerText(String text) {
    return Expanded(
      child: Text(text,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 253, 253, 253)),
          textAlign: TextAlign.center),
    );
  }

  Widget _dataText(String text) {
    return Expanded(
      child: Text(text,
          style: TextStyle(
              fontSize: 15, color: Colors.black, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "📊 Growth Analysis",
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic),
        ),
        backgroundColor: const Color.fromARGB(255, 10, 38, 85),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color.fromARGB(255, 13, 171, 210),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4))
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: weightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: "Weight (kg)",
                          prefixIcon: Icon(Icons.monitor_weight)),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: heightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: "Height (cm)",
                          prefixIcon: Icon(Icons.height)),
                    ),
                    SizedBox(height: 20),
                    isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton.icon(
                            onPressed: checkGrowthCalculation,
                            icon: Icon(Icons.check_circle),
                            label: Text("Check Growth"),
                          ),
                    if (isChecked) ...[
                      SizedBox(height: 20),
                      Text("BMI: ${bmi.toStringAsFixed(2)}",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("Z-Score: ${zScore.toStringAsFixed(2)}",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("Status: $status",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green)),
                      SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: saveGrowthRecord,
                        icon: Icon(Icons.save),
                        label: Text("Save Record"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                      ),
                    ]
                  ],
                ),
              ),
              SizedBox(height: 20),
                Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 19, 7, 73),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _headerText("Weight"),
                    _headerText("Height"),
                    _headerText("BMI"),
                    _headerText("Status"),
                    _headerText("Delete"),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: growthRecords.length,
                  itemBuilder: (context, index) {
                    final record = growthRecords[index];
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2)),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _dataText("${record['weight_kg']} kg"),
                          _dataText("${record['height_cm']} cm"),
                          _dataText("${record['bmi'].toStringAsFixed(1)}"),
                          _dataText(record['growth_status']),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteRecord(record['id']),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
                   
            ],
          ),
        ),
      ),
          floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 11, 217, 38), // Custom Color
        shape: CircleBorder(), // Rounded Button
        child: Icon(Icons.smart_toy, size: 30, color: Colors.white), // AI Icon
        onPressed: () {
          // ✅ Smooth Slide Animation to ChatPage
          Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => ChatPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(begin: Offset(1, 0), end: Offset(0, 0)).animate(animation),
                child: child,
              );
            },
          ));
        },
      ),
    );
  }
}
