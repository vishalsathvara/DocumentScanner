import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateScreen extends StatelessWidget {
  const UpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AlertDialog(
          title: const Text('App Update Required'),
          content: const Text('A new version of the app is available. Please update to continue.'),
          actions: [
            TextButton(
              onPressed: () {

                _openAppStore();
              },
              child: const Text('Update Now'),
            ),
          ],
        ),
      ),
    );
  }


  void _openAppStore() async {
    const url = 'https://play.google.com/store/apps/details?id=your.package.name';
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        _showErrorDialog('Could not open the Play Store.');
      }
    } catch (e) {
      _showErrorDialog('Something went wrong while opening the Play Store.');
    }
  }

  void _showErrorDialog(String message) {
    print(message);
  }

}
