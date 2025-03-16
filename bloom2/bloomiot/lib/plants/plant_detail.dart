import 'package:flutter/material.dart';

class PlantDetailScreen extends StatelessWidget {
  final String commonName;
  final String scientificName;
  final String imageUrl;

  const PlantDetailScreen({
    super.key,
    required this.commonName,
    required this.scientificName,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 7,
                child: Container(),
              ),
            ],
          ),
          Positioned(
            top: 60,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.chevron_left, size: 30),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Color(0xFFF9F9F9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$scientificName ($commonName)',
                      style: const TextStyle(
                        color: Color(0xFF1A472A),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getDescription(commonName),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Divider(),
                    const SizedBox(height: 15),
                    const Text(
                      'Favored Conditions',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 13),
                    Row(
                      children: [
                        Expanded(
                          child: _buildConditionCard(
                            icon: Icons.water_drop,
                            title: 'Water',
                            value: _getWaterValue(commonName),
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildConditionCard(
                            icon: Icons.wb_sunny,
                            title: 'Sunlight',
                            value: _getSunlightValue(commonName),
                            color: Colors.deepPurple.shade300,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 13),
                    Row(
                      children: [
                        Expanded(
                          child: _buildConditionCard(
                            icon: Icons.spa,
                            title: 'Fertilizer',
                            value: _getFertilizerValue(commonName),
                            color: Colors.redAccent,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildConditionCard(
                            icon: Icons.grain,
                            title: 'Humidity',
                            value: _getHumidityValue(commonName),
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$commonName added to My Plants'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F4E20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Add to My Plants',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 255, 255, 255)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDescription(String commonName) {
    switch (commonName.toLowerCase()) {
      case 'tomato':
        return 'Tomato is a visually appealing plant that adds elegance and symbolizes prosperity.';
      case 'potato':
        return 'Potatoes are hardy plants that thrive underground, offering sustenance and resilience.';
      case 'chilli':
        return 'Chilli plants bring a fiery zest to gardens with their vibrant peppers.';
      case 'bellpepper':
        return 'Bell peppers are colorful and versatile, enhancing both gardens and dishes.';
      case 'corn':
        return 'Corn stands tall, representing abundance and agricultural heritage.';
      case 'eggplant':
        return 'Eggplants offer deep purple beauty and a unique flavor to any space.';
      default:
        return 'This plant adds beauty and vitality to your space.';
    }
  }

  String _getWaterValue(String commonName) {
    switch (commonName.toLowerCase()) {
      case 'tomato':
        return '250 ml';
      case 'potato':
        return '300 ml';
      case 'chilli':
        return '200 ml';
      case 'bellpepper':
        return '250 ml';
      case 'corn':
        return '350 ml';
      case 'eggplant':
        return '280 ml';
      default:
        return 'Varies';
    }
  }

  String _getSunlightValue(String commonName) {
    switch (commonName.toLowerCase()) {
      case 'tomato':
        return 'Normal';
      case 'potato':
        return 'Partial Sun';
      case 'chilli':
        return 'Full Sun';
      case 'bellpepper':
        return 'Normal';
      case 'corn':
        return 'Full Sun';
      case 'eggplant':
        return 'Normal';
      default:
        return 'Varies';
    }
  }

  String _getFertilizerValue(String commonName) {
    switch (commonName.toLowerCase()) {
      case 'tomato':
        return '70 ml';
      case 'potato':
        return '80 ml';
      case 'chilli':
        return '60 ml';
      case 'bellpepper':
        return '65 ml';
      case 'corn':
        return '90 ml';
      case 'eggplant':
        return '75 ml';
      default:
        return 'Varies';
    }
  }

  String _getHumidityValue(String commonName) {
    switch (commonName.toLowerCase()) {
      case 'tomato':
        return '54%';
      case 'potato':
        return '60%';
      case 'chilli':
        return '50%';
      case 'bellpepper':
        return '55%';
      case 'corn':
        return '65%';
      case 'eggplant':
        return '58%';
      default:
        return 'Varies';
    }
  }

  Widget _buildConditionCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }
}
