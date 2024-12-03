import 'package:document_scan/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the theme provider
    // final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: Colors.orangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Settings Screen'),
            const SizedBox(height: 20),
            const Text('You can add settings options here.'),
            const SizedBox(height: 20),
            // Theme Switch
            // SwitchListTile(
            //   title: const Text('Dark Mode'),
            //   // value: themeProvider.themeMode == ThemeMode.dark, // Check if it's dark mode
            //   onChanged: (bool value) {
            //     // Toggle the theme when the switch is changed
            //     themeProvider.toggleTheme();
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
