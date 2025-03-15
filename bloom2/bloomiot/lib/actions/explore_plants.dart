// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class Plant {
//   final int id;
//   final String name;
//   final String category;
//   final String imageUrl;
//   final String description;

//   Plant({
//     required this.id,
//     required this.name,
//     required this.category,
//     required this.description,
//     required this.imageUrl,
//   });

//   factory Plant.fromJson(Map<String, dynamic> json) {
//     return Plant(
//       id: json['id'],
//       name: json['name'],
//       category: json['category'],
//       description: json['description'],
//       imageUrl: json['image_url'],
//     );
//   }
// }

// class PlantRepository {
//   final SupabaseClient supabase;

//   PlantRepository(this.supabase);

//   Future<List<Plant>> searchPlants(String query) async {
//     final response =
//         await supabase.from('plants').select().ilike('name', '%$query%');

//     if (response.error != null) {
//       throw response.error!.message;
//     }

//     return (response.data as List).map((json) => Plant.fromJson(json)).toList();
//   }
// }

// class ExplorePlantsScreen extends StatefulWidget {
//   const ExplorePlantsScreen({super.key});

//   @override
//   State<ExplorePlantsScreen> createState() => _ExplorePlantsScreenState();
// }

// class _ExplorePlantsScreenState extends State<ExplorePlantsScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   final PlantRepository _plantRepository =
//       PlantRepository(Supabase.instance.client);
//   List<Plant>? _searchResults;
//   bool _isLoading = false;

//   Future<void> _performSearch(String query) async {
//     if (query.isEmpty) {
//       setState(() {
//         _searchResults = null;
//       });
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final results = await _plantRepository.searchPlants(query);
//       setState(() {
//         _searchResults = results;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error searching plants: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4FAF4),
//       appBar: AppBar(
//         centerTitle: true,
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: const BackButton(color: Colors.black),
//         title: const Text(
//           'Explore Plants',
//           style: TextStyle(
//               color: Color(0xFF003300),
//               fontSize: 24,
//               fontWeight: FontWeight.w600),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
//               decoration: BoxDecoration(
//                 color: const Color.fromARGB(255, 255, 255, 255),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: TextField(
//                 controller: _searchController,
//                 onChanged: (value) => _performSearch(value),
//                 decoration: const InputDecoration(
//                   icon: Icon(Icons.search, color: Colors.grey),
//                   hintText: 'Search plants & Flowers',
//                   border: InputBorder.none,
//                   hintStyle: TextStyle(color: Colors.grey),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//             Expanded(
//               child: _isLoading
//                   ? const Center(child: CircularProgressIndicator())
//                   : _searchResults != null
//                       ? _buildSearchResults()
//                       : _buildCategories(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSearchResults() {
//     if (_searchResults!.isEmpty) {
//       return const Center(
//         child: Text('No plants found'),
//       );
//     }

//     return ListView.builder(
//       itemCount: _searchResults!.length,
//       itemBuilder: (context, index) {
//         final plant = _searchResults![index];
//         return Card(
//           margin: const EdgeInsets.only(bottom: 16),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15),
//           ),
//           child: ListTile(
//             contentPadding: const EdgeInsets.all(16),
//             leading: Image.network(
//               plant.imageUrl,
//               width: 60,
//               height: 60,
//               fit: BoxFit.cover,
//             ),
//             title: Text(
//               plant.name,
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF003300),
//               ),
//             ),
//             subtitle: Text(
//               plant.description,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//             onTap: () {
//               // Navigate to plant details screen
//             },
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildCategories() {
//     return GridView.count(
//       crossAxisCount: 2,
//       childAspectRatio: 1.1,
//       crossAxisSpacing: 16,
//       mainAxisSpacing: 16,
//       children: [
//         _buildCategoryCard(
//           'Flowering\nPlants',
//           'assets/plants/flowers.png',
//         ),
//         _buildCategoryCard(
//           'Trees',
//           'assets/plants/tree.png',
//         ),
//         _buildCategoryCard(
//           'Shrubs &\nHerbs',
//           'assets/plants/shrubs.png',
//         ),
//         _buildCategoryCard(
//           'Weeds &\nShrubs',
//           'assets/plants/weeds.png',
//         ),
//       ],
//     );
//   }

//   Widget _buildCategoryCard(String title, String imagePath) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.only(left: 14),
//               child: Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF003300),
//                 ),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(10),
//             child: Image.asset(
//               imagePath,
//               height: 85,
//               fit: BoxFit.contain,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
