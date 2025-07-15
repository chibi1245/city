import 'package:flutter/material.dart';


class Responsive extends StatelessWidget {
  final Widget mobile;
  const Responsive({super.key, required this.mobile}); // Added super.key

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      var screenSize = constraints.maxWidth;
      if (screenSize <= 375) {
        return mobile;
      } else if (screenSize > 375 && screenSize < 601) {
        return mobile;
      } else if (screenSize >= 601 && screenSize < 1024) {
        return NoSupportView();
      } else if (screenSize >= 1024) {
        return NoSupportView();
      } else {
        return NoSupportView();
      }
    });
  }
}

// You will need to define NoSupportView if it's not already defined elsewhere.
// Ensure NoSupportView itself does not contain business logic.
class NoSupportView extends StatelessWidget {
  const NoSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unsupported Device')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber, size: 80, color: Colors.orange),
            SizedBox(height: 20),
            Text(
              'Device Not Supported',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Please use a mobile device to access this application.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}