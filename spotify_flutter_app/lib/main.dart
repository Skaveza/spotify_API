import 'package:flutter/material.dart';
import 'package:spotify_flutter_app/screens/login.dart';
import 'package:spotify_flutter_app/screens/home.dart';
import 'package:spotify_flutter_app/screens/playlist.dart';

void main() {
  runApp(const SpotifyApp());
}

class SpotifyApp extends StatelessWidget {
  const SpotifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Spotify Clone",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
          brightness: Brightness.dark,
          primary: Colors.pink,
        ),
        scaffoldBackgroundColor: Colors.pink,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.pink,
          elevation: 20,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        textTheme: TextTheme(
          bodyLarge: const TextStyle(color: Colors.white),
          bodyMedium: const TextStyle(color: Colors.white),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => LoginScreen());

          case '/home':
            final accessToken = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => HomeScreen(accessToken: accessToken),
            );

          case '/playlist':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => PlaylistScreen(
                accessToken: args['accessToken'], // Ensure only accessToken is passed
              ),
            );

          default:
            return MaterialPageRoute(builder: (_) => LoginScreen());
        }
      },
    );
  }
}