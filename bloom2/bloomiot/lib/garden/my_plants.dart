import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'schedule.dart';
import 'package:bloomiot/plants/plant_detail.dart';
import 'package:bloomiot/actions/plant_select.dart'; // You'll need to create this file for PlantSelectionScreen

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
        return {'plants': plantData};
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

  Widget _getPlantPage(String commonName, String scientificName) {
    final normalizedName = commonName.toLowerCase().replaceAll(' ', '_');
    String imageUrl;
    switch (normalizedName) {
      case 'tomato':
        imageUrl =
            'https://images.unsplash.com/photo-1592841200221-a6898f307baa?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80';
        break;
      case 'potato':
        imageUrl =
            'https://images.unsplash.com/photo-1518977676601-b53f82aba655?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80';
        break;
      case 'chilli':
        imageUrl =
            'https://images.unsplash.com/photo-1588252303782-cb80119abd6d?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80';
        break;
      case 'bellpepper':
        imageUrl =
            'https://images.unsplash.com/photo-1526470498-9ae73c665de8?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80';
        break;
      case 'corn':
        imageUrl =
            'https://images.unsplash.com/photo-1551754655-cd27e38d2076?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80';
        break;
      case 'eggplant':
        imageUrl =
            'https://cdn.pixabay.com/photo/2016/09/10/17/47/eggplant-1659784_1280.jpg';
        break;
      default:
        imageUrl =
            'https://images.unsplash.com/photo-1444853602635-9e634e3e4e43?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80';
    }

    return PlantDetailScreen(
      commonName: commonName,
      scientificName: scientificName,
      imageUrl: imageUrl,
    );
  }

  String _getPlantImage(String? commonName) {
    if (commonName == null || commonName.isEmpty) {
      return 'assets/plants/default.png';
    }
    final normalizedName = commonName.toLowerCase().replaceAll(' ', '_');
    return 'assets/plants/$normalizedName.png';
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons
                  .sentiment_dissatisfied_sharp, // Using a cross icon similar to your image
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No plants associated with your account',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate to Plant Selection screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PlantSelectionScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Add Plants',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          _getPlantPage(commonName, scientificName),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
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
                  color: const Color(0xFFE2E2E2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.spa,
                        color: Color.fromARGB(255, 14, 63, 16));
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
