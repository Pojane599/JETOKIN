import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'FullscreenVideoPlayer.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String url;

  const VideoPlayerScreen({Key? key, required this.url}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..setVolume(1.0) // Pastikan volume aktif
      ..initialize().then((_) {
        setState(() {}); // Update UI setelah video siap
      }).catchError((error) {
        debugPrint('Error loading video: $error');
      });

    // Tambahkan Listener untuk mendeteksi jika video selesai
    _controller.addListener(() {
      if (_controller.value.isInitialized) {
        if (_controller.value.position >= _controller.value.duration) {
          // Video selesai diputar
          setState(() {
            _isPlaying = false; // Pastikan tombol play/pause diperbarui
          });
          // Tampilkan loading selama beberapa detik
          Future.delayed(const Duration(seconds: 1), () {
            _controller.seekTo(Duration.zero); // Reset ke awal
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Jangan lupa dispose controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Sudut melengkung
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Dialog
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     const Text(
              //       "Video",
              //       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              //     ),
              //     IconButton(
              //       icon: const Icon(Icons.close),
              //       onPressed: () => Navigator.pop(context),
              //     ),
              //   ],
              // ),
              const SizedBox(height: 10),

              // Video Player
              _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: Stack(
                        children: [
                          VideoPlayer(_controller),
                          if (!_isPlaying &&
                              _controller.value.position >=
                                  _controller.value.duration)
                            const Center(
                                child: CircularProgressIndicator()), // Loading
                        ],
                      ),
                    )
                  : const Center(child: CircularProgressIndicator()),

              // Kontrol Video
              if (_controller.value.isInitialized) ...[
                const SizedBox(height: 16),
                // Slider Kontrol Posisi
                Slider(
                  min: 0,
                  max: _controller.value.duration.inSeconds.toDouble(),
                  value: _controller.value.position.inSeconds.toDouble(),
                  onChanged: (value) {
                    setState(() {
                      _controller.seekTo(Duration(seconds: value.toInt()));
                    });
                  },
                ),
                // Tombol Play/Pause dan Stop
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.blue,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_controller.value.isPlaying) {
                            _controller.pause();
                            _isPlaying = false;
                          } else {
                            _controller.play();
                            _isPlaying = true;
                          }
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.stop, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _controller.pause();
                          _controller.seekTo(Duration.zero);
                          _isPlaying = false;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.fullscreen, color: Colors.green),
                      onPressed: () {
                        // Navigasi ke layar penuh (jika diperlukan)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullscreenVideoPlayer(
                              controller: _controller,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                // Indikator Waktu
                Text(
                  '${_controller.value.position.inMinutes}:${_controller.value.position.inSeconds.remainder(60).toString().padLeft(2, '0')} / '
                  '${_controller.value.duration.inMinutes}:${_controller.value.duration.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
