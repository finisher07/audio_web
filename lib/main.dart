import 'dart:async';
import 'dart:developer';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
      title: "Music Player",
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String musicUrl = "http://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Kangaroo_MusiQue_-_The_Neverwritten_Role_Playing_Game.mp3";
  String thumbnailImgUrl = "https://www.raptier.com/backend/raptier/public/api/get-object/1706789379_scaled_download.jpeg";
  var player = AudioPlayer();
  bool loaded = false;
  bool playing = false;
  Timer? timer;

  Duration _totalPlayedTime = const Duration(seconds: -3);

  void loadMusic() async {
    await player.setUrl(musicUrl);
    setState(() {
      loaded = true;
    });
  }

  void playMusic() async {
    setState(() {
      playing = true;
    });
    await player.play();
  }

  void pauseMusic() async {
    setState(() {
      playing = false;
    });
    await player.pause();
  }

  @override
  void initState() {
    loadMusic();

    player.createPositionStream(minPeriod: const Duration(seconds: 1),maxPeriod: const Duration(seconds: 1)).listen((event) {
      log("Time : ${_totalPlayedTime.inSeconds}");
      if(_totalPlayedTime.inSeconds == 30){
        log("call api at : ${_totalPlayedTime.inSeconds}");
      }
      _totalPlayedTime += const Duration(seconds: 1);
    });

    super.initState();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Music Player"),
      ),
      body: Column(
        children: [
          const Spacer(
            flex: 2,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              thumbnailImgUrl,
              height: 350,
              width: 350,
              fit: BoxFit.cover,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: StreamBuilder(
                stream: player.positionStream,
                builder: (context, snapshot1) {
                  final Duration duration = loaded
                      ? snapshot1.data as Duration
                      : const Duration(seconds: 0);
                  return StreamBuilder(
                      stream: player.bufferedPositionStream,
                      builder: (context, snapshot2) {
                        final Duration bufferedDuration = loaded
                            ? snapshot2.data as Duration
                            : const Duration(seconds: 0);
                        return SizedBox(
                          height: 30,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ProgressBar(
                              progress: duration,
                              total:
                              player.duration ?? const Duration(seconds: 0),
                              buffered: bufferedDuration,
                              timeLabelPadding: -1,
                              timeLabelTextStyle: const TextStyle(fontSize: 14, color: Colors.black),
                              progressBarColor: Colors.red,
                              baseBarColor: Colors.grey[200],
                              bufferedBarColor: Colors.grey[350],
                              thumbColor: Colors.red,
                              onSeek: loaded ? (duration) async {await player.seek(duration);} : null,
                            ),
                          ),
                        );
                      });
                }),
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(
                width: 10,
              ),
              IconButton(
                  onPressed: loaded
                      ? () async {
                    if (player.position.inSeconds >= 10) {
                      await player.seek(Duration(
                          seconds: player.position.inSeconds - 10));
                    } else {
                      await player.seek(const Duration(seconds: 0));
                    }
                  }
                      : null,
                  icon: const Icon(Icons.fast_rewind_rounded)),
              Container(
                height: 50,
                width: 50,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.red),
                child: IconButton(
                    onPressed: loaded
                        ? () {
                      if (playing) {
                        pauseMusic();
                      } else {
                        playMusic();
                      }
                    }
                        : null,
                    icon: Icon(
                      playing ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    )),
              ),
              IconButton(
                  onPressed: loaded
                      ? () async {
                    if (player.position.inSeconds + 10 <=
                        player.duration!.inSeconds) {
                      await player.seek(Duration(
                          seconds: player.position.inSeconds + 10));
                    } else {
                      await player.seek(const Duration(seconds: 0));
                    }
                  }
                      : null,
                  icon: const Icon(Icons.fast_forward_rounded)),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
          const Spacer(
            flex: 2,
          )
        ],
      ),
    );
  }
}
