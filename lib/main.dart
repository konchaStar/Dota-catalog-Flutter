import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:untitled/screens/account_screen.dart';
import 'package:untitled/screens/home_screen.dart';
import 'package:untitled/screens/login_screen.dart';
import 'package:untitled/screens/signup_screen.dart';
import 'package:untitled/services/firebase_stream.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyAgDcJFtbn_aLE21ShrI0qxOJfr9WSczgE',
      appId: '1:297605850162:android:1633b43fbc80cf12a0082b',
      messagingSenderId: '297605850162',
      projectId: 'dotacat-ba655',
      storageBucket: 'dotacat-ba655.appspot.com'
    )
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Catalog',
      theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        }),
      ),
      routes: {
        '/': (context) => const FirebaseStream(),
        '/home': (context) => const HomeScreen(),
        '/account': (context) => const AccountScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
      },
      initialRoute: '/',
    );
  }
}

