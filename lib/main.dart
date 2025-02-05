import 'package:events/booking_screen.dart';
import 'package:events/event_list_screen.dart';
import 'package:events/forgot_password_screen.dart';
import 'package:events/home_screen.dart';
import 'package:events/login_screen.dart';
import 'package:events/notification_screen.dart';
import 'package:events/review_screen.dart';
import 'package:events/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:events/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Management App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FirebaseAuth.instance.currentUser != null
          ? HomeScreen()
          : LoginScreen(),
      routes: {
        '/signup': (context) => SignUpScreen(),
        '/forgotPassword': (context) => ForgotPasswordScreen(),
        '/home': (context) => HomeScreen(),
        '/eventList': (context) => EventListScreen(),
        '/notification': (context) => NotificationScreen(),
        '/review': (context) => ReviewScreen(),
      },
      // Dynamically handle routes with parameters
      onGenerateRoute: (settings) {
        if (settings.name == '/booking') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => BookingScreen(
              eventCategory: args['eventCategory'],
              themes: args['themes'], // Pass the themes here
            ),
          );
        }
        return null; // Return null if route doesn't match
      },
      debugShowCheckedModeBanner: false,
    );
  }
}