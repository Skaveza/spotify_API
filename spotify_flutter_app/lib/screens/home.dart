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
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData(context);
  }

 Future<void> _fetchUserData(BuildContext context) async {
  try {
    final userProfileResponse = await http.get(
      Uri.parse("https://api.spotify.com/v1/me"),
      headers: {'Authorization': 'Bearer ${widget.accessToken}'},
    );

    if (userProfileResponse.statusCode == 200) {
      _userProfile = json.decode(userProfileResponse.body);
    } else {
      throw Exception("Failed to fetch user profile: ${userProfileResponse.statusCode}");
    }

    // Check if the widget is still mounted before using context
    if (!mounted) return;

    final userPlaylistsResponse = await http.get(
      Uri.parse("https://api.spotify.com/v1/me/playlists"),
      headers: {'Authorization': 'Bearer ${widget.accessToken}'},
    );

    if (userPlaylistsResponse.statusCode == 200) {
      _playlists = json.decode(userPlaylistsResponse.body)['items'];
    } else {
      throw Exception("Failed to fetch playlists: ${userPlaylistsResponse.statusCode}");
    }
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error fetching data: $e')),
    );
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      // Stay on Home Screen
    } else if (index == 1) {
      // Navigate to Playlists
      Navigator.pushNamed(context, '/playlist', arguments: {
        'accessToken': widget.accessToken,
      });
    } else if (index == 2) {
      // Navigate to Login screen
      Navigator.pushReplacementNamed(context, '/login');
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
          : (_playlists == null || _playlists!.isEmpty)
              ? Center(child: const Text("No playlists available."))
              : ListView.builder(
                  itemCount: _playlists!.length,
                  itemBuilder: (context, index) {
                    final playlist = _playlists![index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      child: ListTile(
                        title: Text(
                          playlist['name'] ?? 'Unnamed Playlist',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.pink,
                          ),
                        ),
                        subtitle: Text(
                          "${playlist['tracks']['total'] ?? 0} tracks",
                          style: const TextStyle(color: Colors.black54),
                        ),
                        onTap: () {
                          if (playlist['id'] != null) {
                            Navigator.pushNamed(
                              context,
                              '/playlist',
                              arguments: {
                                'playlistId': playlist['id'],
                                'accessToken': widget.accessToken,
                              },
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: 'Playlists',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout',
          ),
        ],
      ),
    );
  }
}