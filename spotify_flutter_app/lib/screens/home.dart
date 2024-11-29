import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  final String accessToken;

  const HomeScreen({super.key, required this.accessToken});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _userProfile;
  List<dynamic>? _playlists;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final userProfileResponse = await http.get(
        Uri.parse("https://api.spotify.com/v1/me"),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );

      final userPlaylistsResponse = await http.get(
        Uri.parse("https://api.spotify.com/v1/me/playlists"),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );

      setState(() {
        _userProfile = json.decode(userProfileResponse.body);
        _playlists = json.decode(userPlaylistsResponse.body)['items'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_userProfile?['display_name'] ?? 'My Playlists'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _playlists?.length ?? 0,
              itemBuilder: (context, index) {
                final playlist = _playlists![index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  child: ListTile(
                    title: Text(
                      playlist['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: Colors.pink,
                      ),
                    ),
                    subtitle: Text(
                      "${playlist['tracks']['total']} tracks",
                      style: const TextStyle(color: Colors.black54),
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/playlist',
                        arguments: {
                          'playlistId': playlist['id'],
                          'accessToken': widget.accessToken,
                        },
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}