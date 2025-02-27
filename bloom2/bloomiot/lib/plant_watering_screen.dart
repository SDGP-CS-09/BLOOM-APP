import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

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

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1B5E20),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1B5E20),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedTime != null) {
      setState(() => _selectedTime = pickedTime);
    }
  }

  Future<void> _saveSchedule() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select date and time!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.02,
            left: MediaQuery.of(context).size.width * 0.04,
            right: MediaQuery.of(context).size.width * 0.04,
          ),
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
      if (schedulesSnapshot.exists && 
          (schedulesSnapshot.value as Map).length >= 4) {
        throw 'Maximum 4 schedules allowed per plant';
      }

      await plantRef.update({'name': _selectedPlant});
      await plantRef.child('schedules').push().set({
        'date': scheduledDateTime.toIso8601String(),
        'duration': _selectedDuration,
        'timestamp': ServerValue.timestamp,
      });

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.02,
            left: MediaQuery.of(context).size.width * 0.04,
            right: MediaQuery.of(context).size.width * 0.04,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 239, 230),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
          child: Column(
            children: [
              _buildHeader(),
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
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          iconSize: MediaQuery.of(context).size.width * 0.06,
          onPressed: () => Navigator.pop(context),
        ),
        Expanded(
          child: Center(
            child: Text(
              'Set Watering',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.06,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B5E20),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlantDropdown() {
    return _buildDropdown(
      label: 'Choose Plant',
      value: _selectedPlant,
      items: _plants,
      onChanged: (value) => setState(() => _selectedPlant = value!),
    );
  }

  Widget _buildDurationDropdown() {
    return _buildDropdown(
      label: 'Duration',
      value: _selectedDuration,
      items: _durations,
      onChanged: (value) => setState(() => _selectedDuration = value!),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF1B5E20),
            fontSize: MediaQuery.of(context).size.width * 0.045,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.015),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            items: items.map((e) => DropdownMenuItem(
              value: e,
              child: Text(
                e,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                ),
              ),
            )).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05,
                vertical: MediaQuery.of(context).size.height * 0.02,
              ),
              border: InputBorder.none,
            ),
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF1B5E20)),
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
            color: const Color(0xFF1B5E20),
            fontSize: MediaQuery.of(context).size.width * 0.045,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.015),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: MediaQuery.of(context).size.height * 0.01,
            ),
            title: Text(
              _selectedDate?.toString().split(' ')[0] ?? 'Select date',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.04,
              ),
            ),
            trailing: const Icon(Icons.calendar_today, color: Color(0xFF1B5E20)),
            onTap: () => _selectDate(context),
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
            color: const Color(0xFF1B5E20),
            fontSize: MediaQuery.of(context).size.width * 0.045,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.015),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: MediaQuery.of(context).size.height * 0.01,
            ),
            title: Text(
              _selectedTime?.format(context) ?? 'Select time',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.04,
              ),
            ),
            trailing: const Icon(Icons.access_time, color: Color(0xFF1B5E20)),
            onTap: () => _selectTime(context),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.03),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.07,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E20).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _saveSchedule,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1B5E20),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          'Save Schedule',
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.045,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}