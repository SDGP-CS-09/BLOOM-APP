import 'package:flutter/material.dart';
import 'package:bloomiot/auth/signin_screen.dart';
import 'package:bloomiot/mainscreens/home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart'; // Add this dependency

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  // Logout handler
  void _handleLogout(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => SignInScreen()),
      (Route<dynamic> route) => false,
    );
  }

  // Back button handler
  void _handleBack(BuildContext context) {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
  }

  // Unsubscribe handler
  Future<void> _handleUnsubscribe(BuildContext context) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser; // Get current logged-in user
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user logged in')),
      );
      return;
    }

    final response = await supabase
        .from('api_data')
        .select('sub_id')
        .eq('user_id', user.id) // Match with current user's ID
        .single(); // Assuming one record per user
    final subId =
        response['sub_id'] as String? ?? 'tel:94716177301'; // Default if null

    final url = Uri.parse('http://56.228.42.92:8000/subscription/send');
    final responseApi = await http.post(
      url,
      headers: {'Content-Type': 'application/json;charset=utf-8'},
      body: jsonEncode({
        'applicationId': 'APP_009348', // Replace with your app ID
        'password':
            '953fe2fee66c8b602c05284a8f98f090', // Replace with your password
        'subscriberId': subId,
        'action': '0',
      }),
    );

    if (responseApi.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unsubscription successful')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unsubscription failed: ${responseApi.body}')),
      );
    }
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
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1B5E20),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF4FAF4),
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        children: [
          SizedBox(height: 20),
          _buildSectionTitle('Account Settings'),
          _buildSettingCard(
            icon: Icons.person_outline_rounded,
            text: 'Edit profile',
            onTap: () {},
          ),
          _buildSettingCard(
            icon: Icons.language_rounded,
            text: 'Change language',
            onTap: () {},
          ),
          _buildSettingCard(
            icon: Icons.privacy_tip_outlined,
            text: 'Privacy',
            onTap: () {},
          ),
          SizedBox(height: 20),
          _buildSectionTitle('Legal'),
          _buildSettingCard(
            icon: Icons.description_outlined,
            text: 'Terms and Condition',
            hasExternalLink: true,
            onTap: () {},
          ),
          _buildSettingCard(
            icon: Icons.security_outlined,
            text: 'Privacy policy',
            hasExternalLink: true,
            onTap: () {},
          ),
          _buildSettingCard(
            icon: Icons.help_outline_rounded,
            text: 'Help',
            hasExternalLink: true,
            onTap: () {},
          ),
          SizedBox(height: 20),
          _buildUnsubscribeCard(context), // New unsubscribe button
          _buildLogoutCard(context),
          SizedBox(height: 40),
          Center(
            child: Text(
              'Version 2.0.0',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildUnsubscribeCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xBBDEFB), // Light blue background
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.unsubscribe_rounded, // Unsubscribe icon
            color: Colors.blue.shade700,
            size: 24,
          ),
        ),
        title: Text(
          'Unsubscribe Mspace',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1976D2), // Blue text
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: const Color(0xFF1976D2), // Blue chevron
        ),
        onTap: () => _handleUnsubscribe(context),
      ),
    );
  }

  Widget _buildLogoutCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFCDD2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.logout_rounded,
            color: Colors.red.shade700,
            size: 24,
          ),
        ),
        title: Text(
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: const Color(0xFFC62828),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: const Color(0xFFD32F2F),
        ),
        onTap: () => _handleLogout(context),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String text,
    VoidCallback? onTap,
    bool hasExternalLink = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFE2E2E2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF003300), size: 24),
        ),
        title: Text(
          text,
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
        ),
        trailing: hasExternalLink
            ? Icon(
                Icons.open_in_new_rounded,
                color: Colors.grey.shade600,
                size: 20,
              )
            : Icon(Icons.chevron_right_rounded, color: Colors.grey.shade600),
        onTap: onTap,
      ),
    );
  }
}
