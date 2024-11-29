import 'package:flutter/material.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const String _clientId = "364206692f0e4b0aad5a4234f3b2d161";
  static const String _redirectUri = "myflutterapp://callback";
  static const String _scopes = "user-read-private playlist-read-private";

  Future<void> _authenticateUser(BuildContext context) async {
    final authUrl = 
        "https://accounts.spotify.com/authorize?client_id=$_clientId"
        "&response_type=token"
        "&redirect_uri=$_redirectUri"
        "&scope=$_scopes";

    try {
      final result = await FlutterWebAuth.authenticate(
        url: authUrl,
        callbackUrlScheme: "myflutterapp",
      );

      final accessToken = Uri.parse(result).fragment
          .split("&")
          .firstWhere((element) => element.startsWith("access_token"))
          .split("=")[1];

      Navigator.pushReplacementNamed(context, '/home', arguments: accessToken);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Spotify Login"),
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.pink,
            backgroundColor: Colors.white,
            elevation: 5,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 16,
            ),
          ),
          onPressed: () => _authenticateUser(context),
          child: const Text("Login with Spotify"),
        ),
      ),
    );
  }
}