import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  // Adding a small delay to ensure the framework sets up listeners
  WidgetsFlutterBinding.ensureInitialized();
  Future.delayed(Duration(milliseconds: 100), () {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WaterLevelPage(),
    );
  }
}

class WaterLevelPage extends StatefulWidget {
  @override
  _WaterLevelPageState createState() => _WaterLevelPageState();
}

class _WaterLevelPageState extends State<WaterLevelPage> {
  double waterLevel = 0.0;
  Random random = Random();

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), (Timer t) => fetchWaterLevel());
  }

  fetchWaterLevel() {
    setState(() {
      waterLevel = random.nextInt(100) / 100.0;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Water level updated: ${(waterLevel * 100).toInt()} cm (${(waterLevel * 100).toStringAsFixed(0)}%)'),
          duration: Duration(seconds: 1),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isHighLevel = waterLevel >= 0.85;
    Color waterColor = isHighLevel ? Colors.red : Colors.blue.withOpacity(0.7);
    Color buzzerColor = isHighLevel ? Colors.red : Colors.blueAccent;

    return Scaffold(
      appBar: AppBar(
        title: Text('Water Level Detector'),
        backgroundColor: buzzerColor,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            color: buzzerColor,
            onPressed: () {
              // Buzzer action can be added here
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.blue[900]!],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Live Water Level',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                child: LinearProgressIndicator(
                  value: waterLevel,
                  minHeight: 20,
                  backgroundColor: Colors.grey[300],
                  color: waterColor,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '${(waterLevel * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 40),
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  ClipPath(
                    clipper: PotClipper(),
                    child: Container(
                      width: 200,
                      height: 300,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 2),
                        color: Colors.white,
                      ),
                    ),
                  ),
                  ClipPath(
                    clipper: PotClipper(),
                    child: AnimatedContainer(
                      duration: Duration(seconds: 1),
                      width: 200,
                      height: 300 * waterLevel,
                      decoration: BoxDecoration(
                        color: waterColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchWaterLevel,
        backgroundColor: buzzerColor,
        child: Icon(Icons.refresh),
      ),
    );
  }
}

class PotClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double potWidth = size.width;
    double potHeight = size.height;

    path.moveTo(potWidth * 0.2, 0);
    path.lineTo(potWidth * 0.8, 0);
    path.quadraticBezierTo(potWidth, potHeight * 0.2, potWidth, potHeight * 0.4);
    path.lineTo(potWidth, potHeight);
    path.lineTo(0, potHeight);
    path.lineTo(0, potHeight * 0.4);
    path.quadraticBezierTo(0, potHeight * 0.2, potWidth * 0.2, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
