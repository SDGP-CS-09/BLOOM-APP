import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

class PlantRecognitionScreen extends StatefulWidget {
  const PlantRecognitionScreen({super.key});

  @override
  _PlantRecognitionScreenState createState() => _PlantRecognitionScreenState();
}

class _PlantRecognitionScreenState extends State<PlantRecognitionScreen> {
  File? _image;
  String _errorMessage = '';
  Map<String, dynamic>? _plantData;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  static const String _plantNetApiKey = '2b108O6ZMXegZ0z8HgQuA6lTu';
  static const Map<String, String> _specializedAPIs = {
    'bell_pepper': 'https://bellpepper-production.up.railway.app/predict',
    'corn': 'https://corn-production.up.railway.app/predict',
    'eggplant': 'https://eggplant-production.up.railway.app/predict',
    'potato': 'https://potato-production.up.railway.app/predict',
  };

  Future<bool> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.photos,
    ].request();

    return statuses[Permission.camera]!.isGranted &&
        statuses[Permission.photos]!.isGranted;
  }

  Future<void> _captureImage() async {
    try {
      if (await _requestPermissions()) {
        final XFile? image =
            await _picker.pickImage(source: ImageSource.camera);
        if (image != null) {
          setState(() {
            _image = File(image.path);
            _errorMessage = '';
            _plantData = null;
          });
          await _analyzePlant();
        }
      } else {
        setState(() {
          _errorMessage = 'Camera and gallery permissions are required';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error capturing image: $e';
      });
    }
  }

  Future<void> _uploadImage() async {
    try {
      if (await _requestPermissions()) {
        final XFile? image =
            await _picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          setState(() {
            _image = File(image.path);
            _errorMessage = '';
            _plantData = null;
          });
          await _analyzePlant();
        }
      } else {
        setState(() {
          _errorMessage = 'Gallery permissions are required';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error uploading image: $e';
      });
    }
  }

  Future<void> _analyzePlant() async {
    if (_image == null) {
      setState(() {
        _errorMessage = 'No image selected';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final plantNetResult = await _checkWithPlantNet();

      if (plantNetResult != null) {
        final topResult = plantNetResult as Map<String, dynamic>;
        final score = (topResult['score'] as num?)?.toDouble() ?? 0.0;
        final species = topResult['species'] as Map<String, dynamic>? ?? {};
        final scientificName =
            species['scientificNameWithoutAuthor']?.toString().toLowerCase() ??
                '';
        final commonNames = (species['commonNames'] as List<dynamic>?)
                ?.map((name) => name.toString().toLowerCase())
                .toList() ??
            [];

        // Check if it's one of our specialized plants
        String? specializedKey;
        for (var key in _specializedAPIs.keys) {
          if (scientificName.contains(key) ||
              commonNames.any((name) => name.contains(key))) {
            specializedKey = key;
            break;
          }
        }

        if (specializedKey != null && score >= 0.7) {
          await _analyzeWithSpecializedAPI(_specializedAPIs[specializedKey]!);
        } else {
          setState(() {
            _plantData = {
              'name': scientificName.isNotEmpty
                  ? scientificName
                  : (commonNames.isNotEmpty
                      ? commonNames.first
                      : 'Unknown Plant'),
              'confidence': (score * 100).toStringAsFixed(2),
              'source': 'PlantNet'
            };
          });
        }
      } else {
        setState(() {
          _errorMessage = 'No plant identified';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Analysis error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>?> _checkWithPlantNet() async {
    try {
      final url = Uri.parse(
          'https://my-api.plantnet.org/v2/identify/all?api-key=$_plantNetApiKey&lang=en');
      var request = http.MultipartRequest('POST', url)
        ..fields['organs'] = 'leaf'
        ..files.add(await http.MultipartFile.fromPath('images', _image!.path));

      final response =
          await request.send().timeout(const Duration(seconds: 30));
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseData) as Map<String, dynamic>;
        if (jsonResponse['results']?.isNotEmpty ?? false) {
          return jsonResponse['results'][0] as Map<String, dynamic>;
        }
        return null;
      } else {
        throw Exception(
            'PlantNet API error: Status ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('PlantNet API Exception: $e');
      throw Exception('PlantNet API failed: $e');
    }
  }

  Future<void> _analyzeWithSpecializedAPI(String apiUrl) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files
          .add(await http.MultipartFile.fromPath('file', _image!.path));

      final response =
          await request.send().timeout(const Duration(seconds: 30));
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseData);
        setState(() {
          _plantData = {
            'name': jsonResponse['class'] ?? 'Unknown',
            'confidence': ((jsonResponse['confidence'] as num?) ?? 0.0 * 100)
                .toStringAsFixed(2),
            'source': 'Specialized Model'
          };
        });
      } else {
        throw Exception(
            'Specialized API failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Specialized API error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Stack(
          children: [
            // Loading overlay
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.45),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.green),
                ),
              ),

            // Back button
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            // Message banner
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  _errorMessage.isNotEmpty
                      ? _errorMessage
                      : 'Capture or Upload a Plant Image',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // Image preview
            Center(
              child: Container(
                height: 300,
                width: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                  color: Colors.grey[200],
                ),
                child: _image != null
                    ? Image.file(_image!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.error))
                    : const Center(child: Icon(Icons.camera_alt, size: 50)),
              ),
            ),

            // Results or buttons
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: _plantData != null
                  ? _buildPlantInfoCard()
                  : _buildActionButtons(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Name: ${_plantData?['name'] ?? 'Unknown'}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Confidence: ${_plantData?['confidence'] ?? 'N/A'}%',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          Text(
            'Source: ${_plantData?['source'] ?? 'Unknown'}',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: _isLoading ? null : _captureImage,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Capture Image',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: _isLoading ? null : _uploadImage,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.green, width: 2),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Upload Image',
            style: TextStyle(color: Colors.green, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
