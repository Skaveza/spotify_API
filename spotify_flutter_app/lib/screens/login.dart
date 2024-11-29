import 'package:flutter/material.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:logging/logging.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final Logger _logger = Logger('LoginScreen');
  final String _clientId = "364206692f0e4b0aad5a4234f3b2d161";
  final String _redirectUri = "spotifyflutterapp://callback";
  final String _scopes = 
    "user-read-private "
    "user-read-email "
    "user-library-read "
    "user-library-modify "
    "playlist-read-private "
    "playlist-read-collaborative "
    "playlist-modify-private "
    "playlist-modify-public "
    "user-read-playback-state "
    "user-modify-playback-state "
    "user-read-currently-playing "
    "user-follow-read "
    "user-follow-modify "
    "user-top-read";

 @override
void initState() {
  super.initState();
  if (Logger.root.level == Level.OFF) {
    Logger.root.level = Level.ALL; // Enable all logging levels
    Logger.root.onRecord.listen((record) {
      debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    });
  }
  _logger.info("LoginScreen initialized.");
}

  Future<void> _authenticateUser() async {
    _logger.info("Authentication initiated");
    final authUrl = 
        "https://accounts.spotify.com/authorize?client_id=$_clientId"
        "&response_type=token"
        "&redirect_uri=$_redirectUri"
        "&scope=$_scopes";

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final result = await FlutterWebAuth.authenticate(
        url: authUrl,
        callbackUrlScheme: "spotifyflutterapp",
      );

      if (!mounted) return;

      final accessToken = Uri.parse(result).fragment
          .split("&")
          .firstWhere((element) => element.startsWith("access_token"), orElse: () => "")
          .split("=")[1];

      if (accessToken.isEmpty) {
        throw Exception("Failed to retrieve access token.");
      }

      _logger.info("Successfully authenticated user.");
      Navigator.pushReplacementNamed(context, '/home', arguments: accessToken);
    } catch (e) {
      if (!mounted) return;
      _logger.severe("Authentication failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication failed: $e')),
      );
    } finally {
      if (mounted) Navigator.of(context).pop(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Center(
        child: ElevatedButton(
          onPressed: _authenticateUser,
          child: Text("Login with Spotify"),
        ),
      ),
    );
  }
}