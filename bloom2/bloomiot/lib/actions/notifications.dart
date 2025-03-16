import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF1F8F1),
      ),
      home: const NotificationsScreen(),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                      onPressed: () {},
                    ),
                  ),
                  const Text(
                    "Notifications",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A21),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Today Section
              const Text(
                "Today",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A21),
                ),
              ),
              const SizedBox(height: 16),

              // Today Notifications
              NotificationCard(
                imagePath: "assets/plant1.png",
                title: "Time to hydrate!",
                subtitle: "Drink a glass of water",
                timeAgo: "6 min ago",
                isActive: true,
              ),
              const SizedBox(height: 16),
              NotificationCard(
                imagePath: "assets/plant2.png",
                title: "our mental health matters.",
                subtitle: "",
                timeAgo: "26 min ago",
                isActive: true,
              ),
              const SizedBox(height: 30),

              // Yesterday Section
              const Text(
                "Yesterday",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A21),
                ),
              ),
              const SizedBox(height: 16),

              // Yesterday Notifications
              NotificationCard(
                imagePath: "assets/plant3.png",
                title: "Time to hydrate!",
                subtitle: "Drink a glass of water",
                timeAgo: "4 day ago",
                isActive: false,
              ),
              const SizedBox(height: 16),
              NotificationCard(
                imagePath: "assets/plant4.png",
                title: "Our mental health matters.",
                subtitle: "",
                timeAgo: "4 day ago",
                isActive: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final String timeAgo;
  final bool isActive;

  const NotificationCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Plant Image
            Container(
              width: 80,
              height: 80,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: PlantImage(index: imagePath),
            ),
            const SizedBox(width: 16),

            // Notification Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E3A21),
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF3A3A3A),
                      ),
                    ),
                ],
              ),
            ),

            // Time and Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timeAgo,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? Colors.green.shade900 : Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Custom widget to display different plant images
class PlantImage extends StatelessWidget {
  final String index;

  const PlantImage({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    // In a real app, these would be actual image assets
    // For this example, we'll create colored placeholder containers
    Map<String, Widget> plants = {
      "assets/plant1.png": Image.asset('assets/plant1.png',
          errorBuilder: (context, error, stackTrace) =>
              _buildPlantPlaceholder(Colors.green.shade200)),
      "assets/plant2.png": Image.asset('assets/plant2.png',
          errorBuilder: (context, error, stackTrace) =>
              _buildPlantPlaceholder(Colors.green.shade700)),
      "assets/plant3.png": Image.asset('assets/plant3.png',
          errorBuilder: (context, error, stackTrace) =>
              _buildPlantPlaceholder(Colors.green.shade300)),
      "assets/plant4.png": Image.asset('assets/plant4.png',
          errorBuilder: (context, error, stackTrace) =>
              _buildPlantPlaceholder(Colors.green.shade400)),
    };

    return plants[index] ?? _buildPlantPlaceholder(Colors.green);
  }

  Widget _buildPlantPlaceholder(Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.eco,
        color: color,
        size: 40,
      ),
    );
  }
}
