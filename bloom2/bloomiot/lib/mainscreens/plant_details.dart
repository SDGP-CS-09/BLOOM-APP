import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlantDetailsScreen extends StatefulWidget {
  final String plantType;
  final String? disease;

  const PlantDetailsScreen({super.key, required this.plantType, this.disease});

  @override
  _PlantDetailsScreenState createState() => _PlantDetailsScreenState();
}

class _PlantDetailsScreenState extends State<PlantDetailsScreen> {
  String? _details;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPlantDetails();
  }

  Future<void> _fetchPlantDetails() async {
    // Construct the prompt for the LLM API, handling null disease
    String prompt = 'Provide detailed information about ${widget.plantType}';
    if (widget.disease != null) {
      prompt +=
          ' and how to treat ${widget.disease} disease, including symptoms, causes, and care tips.';
    } else {
      prompt += ' including care tips and interesting facts.';
    }
    prompt +=
        ' Return the response in a structured format with sections for description, symptoms (if applicable), causes (if applicable), and care tips.';

    try {
      // Replace this URL with a real free LLM API endpoint (e.g., Hugging Face, Grok API)
      final response = await http.post(
        Uri.parse('https://api.example-llm.com/generate'), // Placeholder URL
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_API_KEY', // Add API key if required
        },
        body: jsonEncode({
          'prompt': prompt,
          'max_tokens': 300, // Adjust based on API requirements
          'temperature': 0.7, // Control creativity of response
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _details = data['response'] as String? ?? 'No details available.';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Failed to fetch details. Status: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching details: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Details'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.green))
            : _errorMessage != null
                ? Center(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  )
                : SingleChildScrollView(
                    child: _buildDetailsWidget(),
                  ),
      ),
    );
  }

  Widget _buildDetailsWidget() {
    if (_details == null || _details!.isEmpty) {
      return const Center(child: Text('No details available.'));
    }

    // Parse the LLM response to structure it (simple parsing for demonstration)
    List<String> sections =
        _details!.split('\n').where((line) => line.isNotEmpty).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections.map((section) {
        if (section.toLowerCase().contains('description:')) {
          return _buildSection(
              'Description', section.split(':').sublist(1).join(':').trim());
        } else if (section.toLowerCase().contains('symptoms:')) {
          return _buildSection(
              'Symptoms', section.split(':').sublist(1).join(':').trim());
        } else if (section.toLowerCase().contains('causes:')) {
          return _buildSection(
              'Causes', section.split(':').sublist(1).join(':').trim());
        } else if (section.toLowerCase().contains('care tips:')) {
          return _buildSection(
              'Care Tips', section.split(':').sublist(1).join(':').trim());
        }
        return const SizedBox.shrink(); // Ignore lines that don’t match
      }).toList(),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content.isEmpty ? 'No information available.' : content,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
