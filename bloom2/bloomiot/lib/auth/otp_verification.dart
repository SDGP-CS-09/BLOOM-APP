import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({super.key});

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  bool _isLoading = false;

  Future<void> _verifyOTP() async {
    if (_formKey.currentState!.validate()) {
      if (!mounted) return;
      setState(() => _isLoading = true);

      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user logged in')),
        );
        return;
      }

      // Fetch referenceNo from api_data for the current user
      final responseRef = await supabase
          .from('api_data')
          .select('reference_no')
          .eq('user_id', user.id)
          .single();
      final referenceNo = responseRef['reference_no'] as String? ?? '';

      if (referenceNo.isEmpty) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No reference number found')),
        );
        return;
      }

      // Prepare JSON body
      final body = {
        'applicationId': 'APP_009348', // Replace with your app ID
        'password':
            '953fe2fee66c8b602c05284a8f98f090', // Replace with your password
        'referenceNo': referenceNo,
        'otp': _otpController.text.trim(),
      };

      // Call OTP verify API
      final url = Uri.parse('http://56.228.42.92:8000/otp/verify');
      final responseApi = await http.post(
        url,
        headers: {'Content-Type': 'application/json;charset=utf-8'},
        body: jsonEncode(body),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (responseApi.statusCode == 200) {
        final responseData = jsonDecode(responseApi.body);
        if (responseData['statusCode'] == 'S1000') {
          // Save subscriberId to api_data
          final subscriberId = responseData['subscriberId'] as String? ?? '';
          await supabase
              .from('api_data')
              .update({'sub_id': subscriberId}).eq('user_id', user.id);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Verification successful')),
          );
          // Redirect to GardenSetupScreen
          Navigator.pushReplacementNamed(
              context, '/garden_setup'); // Adjust route
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Verification failed: ${responseData['statusDetail']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${responseApi.body}')),
        );
      }
    }
  }

  Future<void> _resendOTP() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user logged in')),
      );
      return;
    }

    final responseRef = await supabase
        .from('api_data')
        .select('reference_no')
        .eq('user_id', user.id)
        .single();
    final referenceNo = responseRef['reference_no'] as String? ?? '';

    if (referenceNo.isEmpty) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No reference number found')),
      );
      return;
    }

    final body = {
      'applicationId': 'APP_009348', // Replace with your app ID
      'password':
          '953fe2fee66c8b602c05284a8f98f090', // Replace with your password
      'subscriberId': 'tel:94716177301', // Adjust based on your logic
    };

    final url = Uri.parse('http://56.228.42.92:8000/otp/request');
    final responseApi = await http.post(
      url,
      headers: {'Content-Type': 'application/json;charset=utf-8'},
      body: jsonEncode(body),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (responseApi.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP resent successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resend failed: ${responseApi.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Color(0xFF003300),
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'OTP Verification',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF003300),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Enter the verification code sent to\nyour mobile number',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF707B81),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 8,
                  ),
                  maxLength: 6,
                  decoration: InputDecoration(
                    hintText: '000000',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      letterSpacing: 8,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the OTP';
                    }
                    if (value.length != 6) {
                      return 'OTP must be 6 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: _resendOTP,
                    child: const Text(
                      'Didn\'t receive the code? Resend OTP',
                      style: TextStyle(
                        color: Color(0xFF707B81),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F4E20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Verify',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
}
