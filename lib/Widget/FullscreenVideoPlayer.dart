import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';

class FullscreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;

  const FullscreenVideoPlayer({Key? key, required this.controller})
      : super(key: key);

  @override
  _FullscreenVideoPlayerState createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<FullscreenVideoPlayer> {
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _isPlaying = widget.controller.value.isPlaying;

    // Ubah orientasi layar ke landscape secara default
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  void dispose() {
    // Kembalikan orientasi layar ke default (portrait) saat keluar
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void toggleOrientation() {
    // Fungsi untuk mengubah orientasi layar
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: [
            // Video Player
            Center(
              child: AspectRatio(
                aspectRatio: widget.controller.value.aspectRatio,
                child: VideoPlayer(widget.controller),
              ),
            ),
            // Kontrol Video
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Slider
                  VideoProgressIndicator(
                    widget.controller,
                    allowScrubbing: true,
                    colors: VideoProgressColors(
                      playedColor: Colors.blue,
                      backgroundColor: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Kontrol Tombol
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Tombol Play/Pause
                      IconButton(
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: () {
                          setState(() {
                            if (widget.controller.value.isPlaying) {
                              widget.controller.pause();
                              _isPlaying = false;
                            } else {
                              widget.controller.play();
                              _isPlaying = true;
                            }
                          });
                        },
                      ),
                      // Tombol Stop
                      IconButton(
                        icon: const Icon(
                          Icons.stop,
                          color: Colors.red,
                          size: 30,
                        ),
                        onPressed: () {
                          setState(() {
                            widget.controller.pause();
                            widget.controller.seekTo(Duration.zero);
                            _isPlaying = false;
                          });
                        },
                      ),
                      // Tombol Ubah Orientasi
                      IconButton(
                        icon: const Icon(
                          Icons.screen_rotation,
                          color: Colors.green,
                          size: 30,
                        ),
                        onPressed: () {
                          toggleOrientation();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Tombol Kembali
            Positioned(
              top: 20,
              left: 20,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
