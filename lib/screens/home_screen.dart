import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _streakDays = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<ChartData> _chartData = [];

  @override
  void initState() {
    super.initState();
    _loadStreak();
    _generateDummyData();
  }

  Future<void> _loadStreak() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _streakDays = snapshot['streak'] ?? 0;
      });
    }
  }

  void _generateDummyData() {
    _chartData = [
      ChartData(1, 2),
      ChartData(2, 4),
      ChartData(3, 3),
      ChartData(4, 5),
      ChartData(5, 2),
      ChartData(6, 4),
      ChartData(7, 6),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Streak's")),
        backgroundColor: Colors.pink.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.pink.shade50,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Goal: 3 streak days',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent),
                    ),
                    SizedBox(height: 10),
                    Text('Streak Days: $_streakDays',
                        style: TextStyle(fontSize: 16, color: Colors.black87)),
                    SizedBox(height: 10),
                    Text('Daily Streak: $_streakDays',
                        style: TextStyle(fontSize: 16, color: Colors.black87)),
                    SizedBox(height: 10),
                    Text('Last 30 Days +100%',
                        style: TextStyle(fontSize: 16, color: Colors.black87)),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: SfCartesianChart(
                        primaryXAxis: NumericAxis(),
                        primaryYAxis: NumericAxis(),
                        series: <LineSeries<ChartData, int>>[
                          LineSeries<ChartData, int>(
                            dataSource: _chartData,
                            xValueMapper: (ChartData data, _) => data.day,
                            yValueMapper: (ChartData data, _) => data.value,
                            color: Colors.pinkAccent,
                            markerSettings: MarkerSettings(isVisible: true),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('Keep it up! You\'re on a roll.',
                        style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.green)),
                    SizedBox(height: 10),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/routine');
                        },
                        child:
                            Text('Get Started', style: TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink.shade100,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                        ),
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
}

class ChartData {
  final int day;
  final int value;
  ChartData(this.day, this.value);
}
