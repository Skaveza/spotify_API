import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logging/logging.dart';

class PlaylistScreen extends StatefulWidget {
  final String accessToken;

  const PlaylistScreen({super.key, required this.accessToken});

  @override
  PlaylistScreenState createState() => PlaylistScreenState();
}

class PlaylistScreenState extends State<PlaylistScreen> {
  final Logger _logger = Logger('PlaylistScreen');
  List<dynamic> _playlists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    // Configure logging globally to avoid redundancy
    if (Logger.root.level == Level.OFF) {
      Logger.root.level = Level.ALL;
      Logger.root.onRecord.listen((record) {
        debugPrint('${record.level.name}: ${record.time}: ${record.message}');
      });
    }

    _logger.info("PlaylistScreen initialized.");
    _fetchPlaylists();
  }

  Future<void> _fetchPlaylists() async {
    try {
      _logger.info("Fetching playlists from Spotify API...");
      final response = await http.get(
        Uri.parse("https://api.spotify.com/v1/me/playlists"),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _playlists = data['items'];
          _isLoading = false;
        });
        _logger.info("Playlists fetched successfully. Total playlists: ${_playlists.length}");
      } else {
        throw Exception("Failed to fetch playlists. Status code: ${response.statusCode}");
      }
    } catch (e) {
      if (!mounted) return; // Ensure the widget is still active
      _logger.severe("Error fetching playlists: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching playlists: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Ensure the loading state is updated
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Playlists")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _playlists.isEmpty
              ? const Center(child: Text("No playlists found"))
              : ListView.builder(
                  itemCount: _playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = _playlists[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text(
                          playlist['name'] ?? "Unnamed Playlist",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Tracks: ${playlist['tracks']?['total'] ?? 0}',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          _logger.info("Tapped on playlist: ${playlist['name'] ?? "Unnamed"}");
                          // Navigate to playlist details screen
                          Navigator.pushNamed(
                            context,
                            '/playlistDetails',
                            arguments: {
                              'playlistId': playlist['id'], // Ensure this key is used in the details screen
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