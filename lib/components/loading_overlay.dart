import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;

  const LoadingOverlay({super.key, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Container(
            color: Colors.black45, // Semi-transparent background
            child: const Center(
              child: CircularProgressIndicator(), // Loading spinner
            ),
          )
        : const SizedBox.shrink(); // Empty widget when not loading
  }
}