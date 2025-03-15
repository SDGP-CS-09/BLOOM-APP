import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'schedule.dart';

class GardenScreen extends StatefulWidget {
  const GardenScreen({super.key});

  @override
  State<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends State<GardenScreen> {
  bool _showingMyPlants = true;
  List<Map<String, dynamic>> userPlants = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserPlants();
  }

  Future<void> _fetchUserPlants() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() {
          errorMessage = 'Please log in to view your plants';
          isLoading = false;
        });
        return;
      }

      final userPlantsResponse = await Supabase.instance.client
          .from('user_plants')
          .select('plant_id')
          .eq('user_id', user.id);

      if (userPlantsResponse.isEmpty) {
        setState(() {
          userPlants = [];
          isLoading = false;
          errorMessage = null;
        });
        return;
      }

      final List<int> plantIds =
          List<int>.from(userPlantsResponse.map((item) => item['plant_id']));

      final plantsResponse = await Supabase.instance.client
          .from('plants')
          .select('id, common_name, scientific_name')
          .inFilter('id', plantIds);

      final processedPlants = plantsResponse.map((plantData) {
        return {
          'plants': plantData,
        };
      }).toList();

      setState(() {
        userPlants = List<Map<String, dynamic>>.from(processedPlants);
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load plants: ${e.toString()}';
        isLoading = false;
      });
      print('Error fetching plants: $e');
    }
  }

  // Updated navigation function
  void _navigateToPlantPage(String commonName, String scientificName) {
    // Normalize the common name for page routing
    final pageName = commonName.toLowerCase().replaceAll(' ', '_');

    // Create a map of known plant pages
    final plantPages = {
      'rose': RosePage(scientificName: scientificName),
      'tulip': TulipPage(scientificName: scientificName),
    };

    // Check if we have a specific page for this plant
    Widget destinationPage = plantPages[pageName] ??
        DefaultPlantPage(
            commonName: commonName, scientificName: scientificName);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => destinationPage,
      ),
    );
  }

  Widget _buildMyPlantsScreen() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Text(
          errorMessage!,
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }

    if (userPlants.isEmpty) {
      return const Center(
        child: Text(
          'No plants associated with your account. Add plants in Plant Selection.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: userPlants.map((plant) {
              final plantData = plant['plants'] as Map<String, dynamic>;
              final commonName = plantData['common_name'] ?? 'Unknown Plant';
              final scientificName = plantData['scientific_name'] ?? 'Unknown';
              return PlantCard(
                name: commonName,
                scientificName: scientificName,
                image: _getPlantImage(commonName),
                onTap: () => _navigateToPlantPage(commonName, scientificName),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _getPlantImage(String? commonName) {
    if (commonName == null || commonName.isEmpty) {
      return 'assets/plants/default.png';
    }
    final normalizedName = commonName.toLowerCase().replaceAll(' ', '_');
    return 'assets/plants/$normalizedName.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF4),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'My Garden',
          style: TextStyle(
            color: Color(0xFF1B5E20),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showingMyPlants = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _showingMyPlants
                          ? const Color.fromARGB(255, 31, 78, 32)
                          : const Color.fromARGB(255, 255, 255, 255),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'My Plants',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _showingMyPlants
                            ? Colors.white
                            : const Color(0xFF003300),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showingMyPlants = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !_showingMyPlants
                          ? const Color.fromARGB(255, 31, 78, 32)
                          : const Color.fromARGB(255, 255, 255, 255),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Schedule',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: !_showingMyPlants
                            ? Colors.white
                            : const Color(0xFF003300),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _showingMyPlants
                ? _buildMyPlantsScreen()
                : const ScheduleScreen(),
          ),
        ],
      ),
    );
  }
}

class PlantCard extends StatelessWidget {
  final String name;
  final String scientificName;
  final String image;
  final VoidCallback onTap;

  const PlantCard({
    super.key,
    required this.name,
    required this.scientificName,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.spa, color: Colors.green);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    Text(
                      scientificName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Plant-specific pages
class RosePage extends StatelessWidget {
  final String scientificName;

  const RosePage({super.key, required this.scientificName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rose')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Rose Page'),
            Text('Scientific Name: $scientificName'),
            // Add rose-specific content
          ],
        ),
      ),
    );
  }
}

class TulipPage extends StatelessWidget {
  final String scientificName;

  const TulipPage({super.key, required this.scientificName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tulip')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Tulip Page'),
            Text('Scientific Name: $scientificName'),
            // Add tulip-specific content
          ],
        ),
      ),
    );
  }
}

class DefaultPlantPage extends StatelessWidget {
  final String commonName;
  final String scientificName;

  const DefaultPlantPage({
    super.key,
    required this.commonName,
    required this.scientificName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(commonName)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Plant: $commonName'),
            Text('Scientific Name: $scientificName'),
            const Text('No specific page available'),
          ],
        ),
      ),
    );
  }
}
