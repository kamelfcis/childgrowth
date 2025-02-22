import 'package:child_growth_tracker/pages/add_child_page.dart';
import 'package:child_growth_tracker/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:dots_indicator/dots_indicator.dart'; 

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "title": "📊 Track Your Child's Growth",
      "description": "Easily log and monitor your child's height, weight, and BMI.",
      "image": "assets/track_growth.png",
    },
    {
      "title": "🔔 Get Instant Growth Alerts",
      "description": "Receive real-time alerts for potential growth concerns.",
      "image": "assets/growth_alerts.png",
    },
    {
      "title": "📈 View Detailed Reports",
      "description": "Understand growth trends with interactive charts and insights.",
      "image": "assets/statistics.png",
    }
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 9, 29, 64),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: onboardingData.length,
              itemBuilder: (context, index) {
                return OnboardingContent(
                  title: onboardingData[index]["title"]!,
                  description: onboardingData[index]["description"]!,
                  image: onboardingData[index]["image"]!,
                );
              },
            ),
          ),
          DotsIndicator(
            dotsCount: onboardingData.length,
            position: _currentPage.toDouble(),
            decorator: DotsDecorator(
              activeColor:  const Color.fromARGB(255, 16, 74, 21),
              size: Size.square(10.0),
              activeSize: Size(18.0, 9.0),
              activeShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0)),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                  child: Text("Skip", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage == onboardingData.length - 1) {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                    } else {
                      _pageController.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    backgroundColor: const Color.fromARGB(255, 16, 74, 21),
                  ),
                  child: Text(_currentPage == onboardingData.length - 1 ? "Get Started" : "Next",
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingContent extends StatelessWidget {
  final String title, description, image;

  const OnboardingContent({
    required this.title,
    required this.description,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
      child: Column(
        children: [
          Expanded(child: Image.asset(image, fit: BoxFit.contain)),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 15),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
