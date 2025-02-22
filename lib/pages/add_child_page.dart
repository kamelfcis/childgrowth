import 'package:child_growth_tracker/pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/growth_utils.dart';
import 'growth_record_page.dart';

class AddChildPage extends StatefulWidget {
  @override
  _AddChildPageState createState() => _AddChildPageState();
}

class _AddChildPageState extends State<AddChildPage> with SingleTickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  String selectedGender = "male";
  bool isLoading = false;
  List<Map<String, dynamic>> childrenList = [];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();
    _fetchChildren();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        dobController.text = pickedDate.toIso8601String().split("T")[0];
      });
    }
  }

  void addChild(BuildContext context) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("User not logged in"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    if (nameController.text.isEmpty || dobController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All fields are required!')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await Supabase.instance.client.from('children').insert({
        'parent_id': user.id,
        'full_name': nameController.text,
        'dob': dobController.text,
        'gender': selectedGender,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Child added successfully!'), backgroundColor: Colors.green),
      );

      nameController.clear();
      dobController.clear();
      _fetchChildren();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${error.toString()}"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void deleteChild(String childId) async {
    try {
      await Supabase.instance.client.from('children').delete().eq('id', childId);
      _fetchChildren();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Child deleted successfully!'), backgroundColor: Colors.red),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting child: ${error.toString()}"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "👶 My Children",
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
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              SizedBox(height: 20),

              // Input Form
              AnimatedContainer(
                duration: Duration(milliseconds: 600),
                curve: Curves.easeOut,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Child Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: dobController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Date of Birth',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onTap: () => _selectDate(context),
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedGender,
                      items: ['male', 'female'].map((gender) {
                        return DropdownMenuItem(value: gender, child: Text(gender.toUpperCase()));
                      }).toList(),
                      onChanged: (value) => setState(() => selectedGender = value!),
                      decoration: InputDecoration(
                        labelText: 'Gender',
                        prefixIcon: Icon(Icons.transgender),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () => addChild(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text('Save', style: TextStyle(fontSize: 18, color: Colors.white)),
                          ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // List of Children
              Expanded(
                child: childrenList.isEmpty
                    ? Center(child: Text("No children added yet.", style: TextStyle(color: Colors.white, fontSize: 18)))
                    : ListView.builder(
                        itemCount: childrenList.length,
                        itemBuilder: (context, index) {
                          final child = childrenList[index];
                          return _buildChildCard(child);
                        },
                      ),
              ),
                
            ],
          ),
        ),
      ),
       floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to Statistics Page
                Navigator.push(context, MaterialPageRoute(builder: (context) => DashboardPage()));
            
        },
        label: Text("Show Statistics", style: TextStyle(fontSize: 18)),
        icon: Icon(Icons.bar_chart),
        backgroundColor: const Color.fromARGB(255, 29, 8, 87),
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildChildCard(Map<String, dynamic> child) {
    return Dismissible(
      key: Key(child['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        padding: EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        child: Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      onDismissed: (direction) {
        deleteChild(child['id']);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
          ],
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blueAccent,
            radius: 30,
            child: Icon(Icons.child_care, color: Colors.white, size: 30),
          ),
          title: Text(child['full_name'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          subtitle: Text("DOB: ${child['dob']} • Gender: ${child['gender'].toUpperCase()}"),
          trailing: IconButton(
            icon: Icon(Icons.fitness_center, color: Colors.blueAccent),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => GrowthRecordPage(childId: child['id']),
              ));
            },
          ),
        ),
      ),
    );
  }
}
