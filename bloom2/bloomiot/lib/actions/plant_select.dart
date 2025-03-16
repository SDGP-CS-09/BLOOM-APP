import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bloomiot/mainscreens/home.dart'; // Import HomeScreen from home.dart

class PlantSelectionScreen extends StatefulWidget {
  const PlantSelectionScreen({super.key});

  @override
  State<PlantSelectionScreen> createState() => _PlantSelectionScreenState();
}

class _PlantSelectionScreenState extends State<PlantSelectionScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<int> selectedPlantIds = []; // Track selected plant IDs
  List<Map<String, dynamic>> plants = []; // Store plants from the database
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPlants();
  }

  Future<void> _fetchPlants() async {
    try {
      final response = await supabase
          .from('plants')
          .select(
              'id, common_name, water_ml, sunlight, fertilizer_ml, humidity_percent')
          .limit(6); // Fetch only the first 6 plants

      setState(() {
        plants = List<Map<String, dynamic>>.from(response);
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load plants: ${e.toString()}';
      });
    }
  }

  Future<void> _saveSelectedPlants() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() {
        errorMessage = 'Please log in to select plants';
      });
      return;
    }

    try {
      final existingPlants = await supabase
          .from('user_plants')
          .select('plant_id')
          .eq('user_id', user.id);

      List<int> existingPlantIds = List<int>.from(
          existingPlants.map((plant) => plant['plant_id'] as int));

      if (selectedPlantIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one plant')),
        );
        return;
      }

      List<int> newPlantIds = selectedPlantIds
          .where((plantId) => !existingPlantIds.contains(plantId))
          .toList();

      if (newPlantIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No new plants to save')),
        );
        return;
      }

      for (int plantId in newPlantIds) {
        await supabase.from('user_plants').insert({
          'user_id': user.id,
          'plant_id': plantId,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plants saved successfully!')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (Route<dynamic> route) => false,
      );
      setState(() {
        selectedPlantIds.clear();
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to save plants: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF4),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Select Your Plants',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose up to 6 plants you want to care for in this app',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF003300),
                ),
              ),
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              const SizedBox(height: 36),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : plants.isEmpty
                        ? const Center(child: Text('No plants available'))
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.4,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: plants.length,
                            itemBuilder: (context, index) {
                              final bool isSelected = selectedPlantIds
                                  .contains(plants[index]['id']);
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      selectedPlantIds
                                          .remove(plants[index]['id']);
                                    } else if (selectedPlantIds.length < 6) {
                                      selectedPlantIds.add(plants[index]['id']);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'You can only select up to 6 plants'),
                                        ),
                                      );
                                    }
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF1F4E20)
                                        : const Color(0xFFFFFFFF),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF1F4E20)
                                          : const Color(0xFFFFFFFF),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Center(
                                    child: Text(
                                      plants[index]['common_name'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            19, // Larger text for emphasis
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xDD003300),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Skip for now',
                      style: TextStyle(
                        color: const Color(0xFF707B81),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Align(
                alignment: Alignment.centerRight,
                child: FloatingActionButton(
                  onPressed:
                      selectedPlantIds.isNotEmpty ? _saveSelectedPlants : null,
                  backgroundColor: const Color(0xFF1F4E20),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
