import 'package:flutter/material.dart';

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

      // TODO: Add your external API call here
      // Example: await yourApiService.verifyOTP(_otpController.text.trim());
      
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      setState(() => _isLoading = false);
      
      // TODO: Handle API response and navigation
      // If successful, navigate to home screen
      // If error, show error message
    }
  }

  Future<void> _resendOTP() async {
    // TODO: Add your external API call to resend OTP
    // Example: await yourApiService.resendOTP();
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP resent successfully')),
    );
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
                // Back button
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

                // Center the title
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

                // OTP Input Field
                const Text(
                  'Enter OTP',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF003300),
                  ),
                ),
                const SizedBox(height: 8),

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

                // Resend OTP
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

                // Verify Button
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