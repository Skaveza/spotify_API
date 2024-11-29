import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlaylistScreen extends StatefulWidget {
  final String playlistId;
  final String accessToken;

  const PlaylistScreen({
    super.key, 
    required this.playlistId, 
    required this.accessToken,
  });

  @override
  PlaylistScreenState createState() => PlaylistScreenState();
}

class PlaylistScreenState extends State<PlaylistScreen> {
  Map<String, dynamic>? _playlistData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPlaylistData();
  }

  Future<void> _fetchPlaylistData() async {
    try {
      final response = await http.get(
        Uri.parse("https://api.spotify.com/v1/playlists/${widget.playlistId}"),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );

      // Check for successful response
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Playlist Data: $data");

        // Update state with playlist data
        setState(() {
          _playlistData = data;
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load playlist: ${response.reasonPhrase}");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching playlist: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_playlistData?['name'] ?? 'Playlist'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_playlistData?['tracks']['items'].isEmpty ?? true)
              ? const Center(child: Text("No tracks available in this playlist."))
              : ListView.builder(
                  itemCount: _playlistData?['tracks']['items'].length ?? 0,
                  itemBuilder: (context, index) {
                    final track = _playlistData!['tracks']['items'][index]['track'];
                    final artistName = track['artists']?.isNotEmpty == true 
                        ? track['artists'][0]['name'] 
                        : 'Unknown Artist';

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      child: ListTile(
                        title: Text(
                          track['name'] ?? 'Unknown Track',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold, 
                            color: Colors.pink,
                          ),
                        ),
                        subtitle: Text(
                          artistName,
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}