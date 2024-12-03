import 'package:document_scan/document_scanner_screen.dart';
import 'package:document_scan/open_scanner.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart'; // Import Crashlytics
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'scan_data_provider.dart'; // Separate ScanDataProvider file

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter bindings are initialized

  await Firebase.initializeApp(); // Initialize Firebase
  print("Firebase successfully initialized!"); // Debug message

  // Set up Crashlytics to record Flutter errors
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  runApp(
    ShowCaseWidget(
      builder: (context) => MultiProvider(
        providers: [

          ChangeNotifierProvider(create: (_) => ThemeProvider()), // Theme management
          ChangeNotifierProvider(create: (_) => ScanDataProvider()), // Scanned image state management
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'BTScan',
          themeMode: themeProvider.themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.orange,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.orange,
          ),
          home: const OpenScanner(), // Set the home screen
          // home: const DocumentScannerScreen(), // Set the home screen
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}



class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = (_themeMode == ThemeMode.light) ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}