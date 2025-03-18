import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:bloomiot/mainscreens/home.dart'; 

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant Sensor Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: SensorDashboard(),
    );
  }
}

class SensorDashboard extends StatefulWidget {
  const SensorDashboard({super.key});

  @override
  _SensorDashboardState createState() => _SensorDashboardState();
}

class _SensorDashboardState extends State<SensorDashboard> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  double lightLevel = 0;
  double soilMoisture = 0;
  double humidity = 0;
  double temperature = 0;

  @override
  void initState() {
    super.initState();
    _activateListeners();
  }

  void _activateListeners() {
    _database.child('sensors/light_level').onValue.listen((event) {
      final value = event.snapshot.value;
      setState(() {
        lightLevel = _toDouble(value);
      });
    });

    _database.child('sensors/soil_moisture').onValue.listen((event) {
      final value = event.snapshot.value;
      setState(() {
        soilMoisture = _toDouble(value);
      });
    });

    _database.child('sensors/humidity').onValue.listen((event) {
      final value = event.snapshot.value;
      setState(() {
        humidity = _toDouble(value);
      });
    });

    _database.child('sensors/ds18b20_temperature').onValue.listen((event) {
      final value = event.snapshot.value;
      setState(() {
        temperature = _toDouble(value);
      });
    });
  }

  // Helper function to safely convert Object? to double
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return 0.0; // Default to 0.0 for unexpected types
  }

  // Back button handler
  void _handleBack(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF4),
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => _handleBack(context), // Added back button
          color: Colors.black87,
        ),
        title: Text(
          'Plant Sensor Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1B5E20),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF4FAF4),
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  _buildGauge('Light Level', lightLevel, Colors.purple, '%'),
                  SizedBox(height: 32),
                  _buildGauge(
                      'Soil Moisture', soilMoisture, Colors.yellow, '%'),
                  SizedBox(height: 32),
                  _buildGauge('Humidity', humidity, Colors.red, '%'),
                  SizedBox(height: 32),
                  _buildGauge('Temperature', temperature, Colors.orange, '°C'),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGauge(String label, double value, Color color, String unit) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            minimum: 0,
            maximum: label == 'Temperature' ? 50 : 100,
            startAngle: 180,
            endAngle: 0,
            radiusFactor: 0.8,
            showLabels: false,
            showTicks: false,
            axisLineStyle: AxisLineStyle(
              thickness: 10,
              color: Colors.grey[300],
            ),
            ranges: <GaugeRange>[
              GaugeRange(
                startValue: 0,
                endValue: value,
                color: color,
                startWidth: 10,
                endWidth: 10,
              ),
            ],
            pointers: <GaugePointer>[],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                widget: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF003300),
                      ),
                    ),
                    Text(
                      '${value.toStringAsFixed(1)}$unit',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1F4E20),
                      ),
                    ),
                  ],
                ),
                angle: 90,
                positionFactor: 0.5,
              ),
            ],
          ),
        ],
      ),
    );
  }
}