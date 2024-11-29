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
            // Initial route is login, no arguments required here
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          
          case '/home':
            // Extracting accessToken from the arguments to pass to HomeScreen
            final accessToken = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => HomeScreen(accessToken: accessToken),
            );

          case '/playlist':
            // Extracting playlistId and accessToken to pass to PlaylistScreen
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => PlaylistScreen(
                playlistId: args['playlistId'],
                accessToken: args['accessToken'],
              ),
            );

          default:
            // Default route should return to LoginScreen
            return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
      },
    );
  }
}
