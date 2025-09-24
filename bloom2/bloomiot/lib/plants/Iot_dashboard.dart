import 'package:flutter/material.dart';
import 'package:bloomiot/mainscreens/home.dart'; // Assuming this exists based on your existing code

class IoTDashboard extends StatefulWidget {
  const IoTDashboard({super.key});

  @override
  _IoTDashboardState createState() => _IoTDashboardState();
}

class _IoTDashboardState extends State<IoTDashboard> {
  // Plant data structure
  final List<PlantCategory> plantCategories = [
    PlantCategory(
      name: 'Plant Chillies',
      plants: [
        PlantData(id: '01', imageUrl: 'https://images.unsplash.com/photo-1583400797511-3a789b2dd50e?w=400'),
        PlantData(id: '02', imageUrl: 'https://images.unsplash.com/photo-1583400797511-3a789b2dd50e?w=400'),
        PlantData(id: '03', imageUrl: 'https://images.unsplash.com/photo-1583400797511-3a789b2dd50e?w=400'),
      ],
    ),
    PlantCategory(
      name: 'Bell pepper',
      plants: [
        PlantData(id: '01', imageUrl: 'https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=400'),
        PlantData(id: '02', imageUrl: 'https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=400'),
        PlantData(id: '03', imageUrl: 'https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=400'),
      ],
    ),
    PlantCategory(
      name: 'Plant Corn',
      plants: [
        PlantData(id: '01', imageUrl: 'https://images.unsplash.com/photo-1551754655-cd27e38d2076?w=400'),
        PlantData(id: '02', imageUrl: 'https://images.unsplash.com/photo-1551754655-cd27e38d2076?w=400'),
        PlantData(id: '03', imageUrl: 'https://images.unsplash.com/photo-1551754655-cd27e38d2076?w=400'),
      ],
    ),
  ];

  // Back button handler
  void _handleBack(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  // Handle plant card tap
  void _handlePlantTap(String categoryName, String plantId) {
    // Navigate to plant details or sensor data
    // You can replace this with your actual navigation logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tapped on $categoryName - Plant $plantId'),
        backgroundColor: const Color(0xFF1B5E20),
      ),
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
          onPressed: () => _handleBack(context),
          color: Colors.black87,
        ),
        title: Text(
          'IOT Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1B5E20),
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF4FAF4),
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 20),
            // Build plant categories
            ...plantCategories.map((category) => 
              _buildPlantCategoryRow(category)
            ).toList(),
            SizedBox(height: 100), // Space for floating action button
          ],
        ),
      ),
      floatingActionButton: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFF1B5E20),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(
            Icons.qr_code_scanner,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () {
            // Handle QR code scanner
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('QR Code Scanner pressed'),
                backgroundColor: const Color(0xFF1B5E20),
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildPlantCategoryRow(PlantCategory category) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: category.plants.map((plant) => 
          _buildPlantCard(category.name, plant)
        ).toList(),
      ),
    );
  }

  Widget _buildPlantCard(String categoryName, PlantData plant) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: GestureDetector(
          onTap: () => _handlePlantTap(categoryName, plant.id),
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Background image
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Image.network(
                      plant.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback container with plant icon
                        return Container(
                          color: Colors.green[100],
                          child: Icon(
                            Icons.local_florist,
                            size: 40,
                            color: Colors.green[600],
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.green[100],
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                const Color(0xFF1B5E20),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Dark overlay for text readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                  // Content overlay
                  Positioned(
                    left: 12,
                    bottom: 12,
                    right: 50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          categoryName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Plant ${plant.id}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Arrow button
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B5E20),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Data models
class PlantCategory {
  final String name;
  final List<PlantData> plants;

  PlantCategory({
    required this.name,
    required this.plants,
  });
}

class PlantData {
  final String id;
  final String imageUrl;

  PlantData({
    required this.id,
    required this.imageUrl,
  });
}