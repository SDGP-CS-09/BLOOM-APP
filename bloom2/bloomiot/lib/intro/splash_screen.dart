import 'package:flutter/material.dart';

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFF023602),
    body: Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logos/Bloom.png',
                height: 200,
              ),
              const SizedBox(height: 20),
              const Text(
                "BLOOM",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const Positioned(
          left: 0,
          right: 0,
          bottom: 40, // Adjust this value to control distance from bottom
          child: Text(
            "SDGP CS 09",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}
