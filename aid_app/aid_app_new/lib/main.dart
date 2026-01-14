import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import firebase_auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import cloud_firestore
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/auth/login_screen.dart';
import 'screens/splash_screen.dart'; // Import the new screen
import 'utils/app_theme.dart';
import 'services/database_service.dart';
import 'services/auth_service.dart';

void main() async {
  if (isDesktop) {
    sqfliteFfiInit();
  }
  databaseFactory = databaseFactoryFfi;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebase initialization
  _testFirebaseFunction(); // Call the test function
  await DatabaseService.instance.initDb();
  runApp(const MyApp());
}

// Simple test function to demonstrate Firebase usage (anonymous sign-in and Firestore)
void _testFirebaseFunction() async {
  try {
    // Firebase Authentication test
    UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
    print("Signed in anonymously with UID: ${userCredential.user?.uid}");

    // Firestore test
    final firestore = FirebaseFirestore.instance;
    final collectionRef = firestore.collection('test_collection');

    // Write data
    final docRef = await collectionRef.add({
      'timestamp': FieldValue.serverTimestamp(),
      'message': 'Hello from Flutter!',
      'userId': userCredential.user?.uid,
    });
    print("Document written with ID: ${docRef.id}");

    // Read data
    final snapshot = await docRef.get();
    if (snapshot.exists) {
      print("Document data: ${snapshot.data()}");
    } else {
      print("Document does not exist.");
    }

  } catch (e) {
    print("Error during Firebase test: $e");
  }
}

bool get isDesktop {
  return identical(0, 0.0);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'Aid App',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // Automatically uses light or dark theme based on system settings
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}
