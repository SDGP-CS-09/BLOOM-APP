import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:bloomiot/mainscreens/home.dart';

class PlantWateringScreen extends StatefulWidget {
  const PlantWateringScreen({super.key});

  @override
  State<PlantWateringScreen> createState() => _PlantWateringScreenState();
}

class _PlantWateringScreenState extends State<PlantWateringScreen> {
  final _databaseRef = FirebaseDatabase.instance.ref();
  String _selectedPlant = 'Tomato';
  String _selectedDuration = '120 seconds';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _currentMode = 'manual';

  final List<String> _plants = [
    'Tomato',
    'Bellpepper',
    'Chilli',
    'Potato',
    'Egg-plant',
  ];

  final List<String> _durations = [
    '30 seconds',
    '60 seconds',
    '120 seconds',
    '180 seconds',
    '240 seconds',
  ];

  @override
  void initState() {
    super.initState();
    _initializeModeListener();
  }

  void _initializeModeListener() {
    _databaseRef.child('system/mode').onValue.listen((event) {
      final mode = event.snapshot.value?.toString() ?? 'manual';
      if (mounted) {
        setState(() => _currentMode = mode);
      }
    });
  }

  Widget _buildModeWarning() {
    if (_currentMode == 'auto') {
      return Container(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.03),
        decoration: BoxDecoration(
          color: Colors.amber[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Colors.amber, size: MediaQuery.of(context).size.width * 0.05),
            SizedBox(width: MediaQuery.of(context).size.width * 0.03),
            Expanded(
              child: Text(
                'Automatic watering mode is active. Scheduling is disabled.',
                style: TextStyle(
                  color: Colors.amber[800],
                  fontSize: MediaQuery.of(context).size.width * 0.035,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildModeSwitch() {
    return Container(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Watering Mode',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.04,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  _currentMode == 'auto' ? 'Automatic (Soil Moisture)' : 'Manual (Scheduled)',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.035,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _currentMode == 'auto',
            activeColor: const Color(0xFF1B5E20),
            onChanged: (value) => _updateMode(value),
          ),
        ],
      ),
    );
  }

  void _updateMode(bool isAuto) {
    final mode = isAuto ? 'auto' : 'manual';
    _databaseRef.child('system/mode').set(mode).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mode changed to $mode'),
          backgroundColor: const Color(0xFF1B5E20),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1B5E20),
          ),
        ),
        child: child!,
      ),
    );
    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1B5E20),
          ),
        ),
        child: child!,
      ),
    );
    if (pickedTime != null) {
      setState(() => _selectedTime = pickedTime);
    }
  }

  Future<void> _saveSchedule() async {
    if (_currentMode == 'auto') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot save schedule in automatic mode'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date and time!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final scheduledDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final plantKey = _selectedPlant.toLowerCase().replaceAll(' ', '_');
    final plantRef = _databaseRef.child('plants/$plantKey');

    try {
      final schedulesSnapshot = await plantRef.child('schedules').get();
      if (schedulesSnapshot.exists && (schedulesSnapshot.value as Map).length >= 4) {
        throw 'Maximum 4 schedules allowed per plant';
      }

      await plantRef.update({'name': _selectedPlant});
      await plantRef.child('schedules').push().set({
        'date': scheduledDateTime.toIso8601String(),
        'duration': _selectedDuration,
        'timestamp': ServerValue.timestamp,
      });

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF4),
      appBar: AppBar(
        
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: MediaQuery.of(context).size.width * 0.05),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          },
        ),
        title: Text(
          'Create Watering Schedule',
          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.045),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
        child: Column(
          children: [
            _buildModeWarning(),
            _buildModeSwitch(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            _buildPlantDropdown(),
            _buildDatePicker(),
            _buildTimePicker(),
            _buildDurationDropdown(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Plant',
          style: TextStyle(
            color: _currentMode == 'auto' ? Colors.grey : const Color(0xFF1B5E20),
            fontSize: MediaQuery.of(context).size.width * 0.04,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.015),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedPlant,
            items: _plants.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: _currentMode == 'auto'
                ? null
                : (value) => setState(() => _selectedPlant = value!),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04,
                vertical: MediaQuery.of(context).size.height * 0.015,
              ),
              border: InputBorder.none,
            ),
            icon: Icon(Icons.arrow_drop_down,
                color: _currentMode == 'auto' ? Colors.grey : const Color(0xFF1B5E20),
                size: MediaQuery.of(context).size.width * 0.05),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.03),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Date',
          style: TextStyle(
            color: _currentMode == 'auto' ? Colors.grey : const Color(0xFF1B5E20),
            fontSize: MediaQuery.of(context).size.width * 0.04,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.015),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            enabled: _currentMode != 'auto',
            title: Text(
              _selectedDate?.toString().split(' ')[0] ?? 'Select date',
              style: TextStyle(
                color: _currentMode == 'auto' ? Colors.grey : Colors.black,
                fontSize: MediaQuery.of(context).size.width * 0.035,
              ),
            ),
            trailing: Icon(Icons.calendar_today,
                color: _currentMode == 'auto' ? Colors.grey : const Color(0xFF1B5E20),
                size: MediaQuery.of(context).size.width * 0.05),
            onTap: _currentMode == 'auto' ? null : () => _selectDate(context),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.03),
      ],
    );
  }

  Widget _buildTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Time',
          style: TextStyle(
            color: _currentMode == 'auto' ? Colors.grey : const Color(0xFF1B5E20),
            fontSize: MediaQuery.of(context).size.width * 0.04,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.015),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            enabled: _currentMode != 'auto',
            title: Text(
              _selectedTime?.format(context) ?? 'Select time',
              style: TextStyle(
                color: _currentMode == 'auto' ? Colors.grey : Colors.black,
                fontSize: MediaQuery.of(context).size.width * 0.035,
              ),
            ),
            trailing: Icon(Icons.access_time,
                color: _currentMode == 'auto' ? Colors.grey : const Color(0xFF1B5E20),
                size: MediaQuery.of(context).size.width * 0.05),
            onTap: _currentMode == 'auto' ? null : () => _selectTime(context),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.03),
      ],
    );
  }

  Widget _buildDurationDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duration',
          style: TextStyle(
            color: _currentMode == 'auto' ? Colors.grey : const Color(0xFF1B5E20),
            fontSize: MediaQuery.of(context).size.width * 0.04,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.015),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedDuration,
            items: _durations.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: _currentMode == 'auto'
                ? null
                : (value) => setState(() => _selectedDuration = value!),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04,
                vertical: MediaQuery.of(context).size.height * 0.015,
              ),
              border: InputBorder.none,
            ),
            icon: Icon(Icons.arrow_drop_down,
                color: _currentMode == 'auto' ? Colors.grey : const Color(0xFF1B5E20),
                size: MediaQuery.of(context).size.width * 0.05),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.03),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _currentMode == 'auto' ? null : _saveSchedule,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1B5E20),
          padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.02),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Save Schedule',
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.04,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}