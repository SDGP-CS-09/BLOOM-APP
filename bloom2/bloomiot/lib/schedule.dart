import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'plant_watering_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final Map<String, List<Map<String, dynamic>>> _schedulesByDate = {};
  late List<Map<String, dynamic>> _days;
  late DateTime _selectedDate;

  Future<void> _fetchSchedules() async {
    final DataSnapshot snapshot = await _databaseRef.child('plants').get();
    if (!snapshot.exists) return;

    final Map<dynamic, dynamic> plants = snapshot.value as Map<dynamic, dynamic>;
    final Map<String, List<Map<String, dynamic>>> groupedSchedules = {};
    final List<Future<void>> deleteFutures = [];

    plants.forEach((plantKey, plantData) {
      final schedules = (plantData as Map)['schedules'];
      if (schedules != null) {
        schedules.forEach((scheduleKey, scheduleData) {
          final dateString = scheduleData['date'] as String;
          try {
            final scheduleDate = DateTime.parse(dateString).toUtc();
            final now = DateTime.now().toUtc();

            // Check if the schedule is in the past
            if (scheduleDate.isBefore(DateTime(now.year, now.month, now.day, now.hour, now.minute))) {
              // Add to deletion queue
              deleteFutures.add(
                _databaseRef
                    .child('plants/$plantKey/schedules/$scheduleKey')
                    .remove()
                    .catchError((e) => _showError(e.toString())),
              );
            } else {
              // Add to grouped schedules
              final date = dateString.split('T')[0];
              groupedSchedules.putIfAbsent(date, () => []).add({
                'plantName': plantData['name'],
                'plantImage': 'assets/${plantData['name'].toString().toLowerCase()}.jpg',
                'scheduleKey': scheduleKey,
                'plantKey': plantKey,
                'date': dateString,
                'duration': scheduleData['duration'],
              });
            }
          } catch (e) {
            _showError('Invalid date format: $dateString');
          }
        });
      }
    });

    // Wait for all deletions to complete
    await Future.wait(deleteFutures);

    // Update UI
    setState(() {
      _schedulesByDate.clear();
      _schedulesByDate.addAll(groupedSchedules);
    });
  }

  void _deleteSchedule(String plantKey, String scheduleKey) {
    _databaseRef
        .child('plants/$plantKey/schedules/$scheduleKey')
        .remove()
        .then((_) => _fetchSchedules())
        .catchError((e) => _showError(e.toString()));
  }

  void _editSchedule(String plantKey, String scheduleKey, String currentDate) async {
    final dateTime = DateTime.parse(currentDate);
    final newDate = await showDatePicker(
      context: context,
      initialDate: dateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (newDate == null) return;

    final newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(dateTime),
    );
    if (newTime == null) return;

    final newDateTime = DateTime(
      newDate.year,
      newDate.month,
      newDate.day,
      newTime.hour,
      newTime.minute,
    );

    _databaseRef
        .child('plants/$plantKey/schedules/$scheduleKey')
        .update({'date': newDateTime.toIso8601String()})
        .then((_) => _fetchSchedules())
        .catchError((e) => _showError(e.toString()));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
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

  void _initializeDays() {
    final DateTime today = DateTime.now();
    _selectedDate = today;
    _days = List.generate(7, (index) {
      final date = today.add(Duration(days: index));
      return {
        'day': DateFormat('E').format(date),
        'date': DateFormat('d').format(date),
        'fullDate': date,
        'isSelected': index == 0,
      };
    });
  }

  Map<String, List<Map<String, dynamic>>> get _filteredSchedules {
    final selectedDateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    return Map.fromEntries(
      _schedulesByDate.entries.where((entry) => entry.key == selectedDateStr),
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeDays();
    _fetchSchedules();
  }

  Widget _buildCalendar() {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.12,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.04,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: _days.length,
            separatorBuilder: (context, index) => SizedBox(
              width: MediaQuery.of(context).size.width * 0.02,
            ),
            itemBuilder: (context, index) {
              final isSelected = _days[index]['isSelected'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    for (var day in _days) {
                      day['isSelected'] = false;
                    }
                    _days[index]['isSelected'] = true;
                    _selectedDate = _days[index]['fullDate'];
                  });
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.15,
                  margin: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.01,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.03,
                    vertical: MediaQuery.of(context).size.height * 0.01,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1B5E20) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: !isSelected ? Border.all(color: Colors.grey.shade300) : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF1B5E20).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _days[index]['day'],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.w500,
                          fontSize: MediaQuery.of(context).size.width * 0.035,
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.006),
                      Text(
                        _days[index]['date'],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.02,
          ),
          child: Text(
            DateFormat('EEEE').format(_selectedDate),
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.055,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1B5E20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.01,
        bottom: MediaQuery.of(context).size.height * 0.02,
        left: MediaQuery.of(context).size.width * 0.04,
        right: MediaQuery.of(context).size.width * 0.04,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            iconSize: MediaQuery.of(context).size.width * 0.06,
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'Schedule',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.06,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1B5E20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList() {
    final filteredSchedules = _filteredSchedules;

    if (filteredSchedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: MediaQuery.of(context).size.width * 0.15,
              color: Colors.grey[400],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Text(
              'No schedules for ${DateFormat('EEEE').format(_selectedDate)}',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.04,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.04,
      ),
      children: filteredSchedules.entries.map((entry) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...entry.value.map((schedule) => _ScheduleItem(
            plantName: schedule['plantName'],
            imagePath: schedule['plantImage'],
            scheduleKey: schedule['scheduleKey'],
            plantKey: schedule['plantKey'],
            date: schedule['date'],
            duration: schedule['duration'],
            onEdit: () => _editSchedule(
              schedule['plantKey'],
              schedule['scheduleKey'],
              schedule['date'],
            ),
            onDelete: () => _deleteSchedule(
              schedule['plantKey'],
              schedule['scheduleKey'],
            ),
          )),
        ],
      )).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCalendar(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Expanded(child: _buildScheduleList()),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        height: MediaQuery.of(context).size.width * 0.14,
        width: MediaQuery.of(context).size.width * 0.14,
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF1B5E20),
          elevation: 4,
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PlantWateringScreen()),
            );
            if (result == true) _fetchSchedules();
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: MediaQuery.of(context).size.width * 0.07,
          ),
        ),
      ),
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  final String plantName;
  final String imagePath;
  final String scheduleKey;
  final String plantKey;
  final String date;
  final String duration;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ScheduleItem({
    required this.plantName,
    required this.imagePath,
    required this.scheduleKey,
    required this.plantKey,
    required this.date,
    required this.duration,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final time = DateFormat.Hm().format(DateTime.parse(date));

    return Container(
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.015,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
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
          horizontal: MediaQuery.of(context).size.width * 0.04,
          vertical: MediaQuery.of(context).size.height * 0.01,
        ),
        leading: _buildPlantImage(),
        title: Text(
          plantName,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.045,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.005),
            Text(
              'Time: $time',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.035,
              ),
            ),
            Text(
              'Duration: $duration',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.035,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF1B5E20)),
              iconSize: MediaQuery.of(context).size.width * 0.06,
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              iconSize: MediaQuery.of(context).size.width * 0.06,
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantImage() {
    return Builder(
      builder: (context) {
        try {
          return Container(
            width: MediaQuery.of(context).size.width * 0.15,
            height: MediaQuery.of(context).size.width * 0.15,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          );
        } catch (e) {
          return Container(
            width: MediaQuery.of(context).size.width * 0.15,
            height: MediaQuery.of(context).size.width * 0.15,
            color: Colors.grey[200],
            child: Icon(Icons.image_not_supported),
          );
        }
      },
    );
  }
}