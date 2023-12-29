// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:just_audio/just_audio.dart';
import 'dart:math';
import 'dart:async';

class AudioPlayerSingleton {
  static final AudioPlayerSingleton _instance =
      AudioPlayerSingleton._internal();

  factory AudioPlayerSingleton() {
    return _instance;
  }

  AudioPlayerSingleton._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  AudioPlayer get audioPlayer => _audioPlayer;
}

class AdvanceMusicPlayer extends StatefulWidget {
  const AdvanceMusicPlayer({
    Key? key,
    this.width,
    this.height,
    required this.initialUrl,
    required this.musicUrls,
    required this.sliderActiveColor,
    required this.sliderInactiveColor,
    required this.backwardIconPath,
    required this.forwardIconPath,
    required this.backwardIconColor,
    required this.forwardIconColor,
    required this.pauseIconPath,
    required this.playIconPath,
    required this.pauseIconColor,
    required this.playIconColor,
    required this.playbackDurationTextColor,
    required this.previousIconPath,
    required this.nextIconPath,
    required this.previousIconColor,
    required this.nextIconColor,
    required this.startPositionMillis,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String initialUrl;
  final List<String> musicUrls;
  final Color sliderActiveColor;
  final Color sliderInactiveColor;
  final Widget backwardIconPath;
  final Widget forwardIconPath;
  final Color backwardIconColor;
  final Color forwardIconColor;
  final Widget pauseIconPath;
  final Widget playIconPath;
  final Color pauseIconColor;
  final Color playIconColor;

  final Color playbackDurationTextColor;
  final Widget previousIconPath;
  final Widget nextIconPath;
  final Color previousIconColor;
  final Color nextIconColor;

  final double startPositionMillis;

  @override
  _AdvanceMusicPlayerState createState() => _AdvanceMusicPlayerState();
}

class _AdvanceMusicPlayerState extends State<AdvanceMusicPlayer>
    with SingleTickerProviderStateMixin {
  late AudioPlayer audioPlayer;
  bool isPlaying = false;
  Duration totalDuration = Duration.zero;
  Duration currentPosition = Duration.zero;
  int currentSongIndex = 0;
  bool isShuffling = false;
  Timer? _appStatePollingTimer; // Declare the timer here
  String playbackSpeed = '1x';
  String currentAudioUrl = "";

  late AnimationController _animationController;
  // late Animation<double> _fadeAnimation;
  Duration? selectedTimer;
  final List<Duration> timerOptions = [
    Duration(minutes: 1),
    Duration(minutes: 10),
    Duration(minutes: 15),
    Duration(minutes: 20),
    Duration(minutes: 25),
    Duration(minutes: 30),
    Duration(minutes: 35),
    Duration(minutes: 40),
    Duration(minutes: 45),
    Duration(minutes: 50),
    Duration(minutes: 55),
    Duration(minutes: 60),
    Duration(minutes: 90),
    Duration(minutes: 120),
  ];
  Timer? countdownTimer;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayerSingleton().audioPlayer;
    currentAudioUrl = widget.initialUrl;
    audioPlayer.setUrl(widget.initialUrl);
    updatePlayerState();
    // Convert double to Duration
    Duration startPosition =
        Duration(milliseconds: widget.startPositionMillis.toInt());

    audioPlayer.setUrl(widget.initialUrl).then((_) {
      // Seek to the startPosition after setting the URL
      audioPlayer.seek(startPosition);
    });

    audioPlayer.playerStateStream.listen((PlayerState state) {
      setState(() {
        isPlaying = state.playing;
        totalDuration = audioPlayer.duration ?? Duration.zero;
        currentPosition = audioPlayer.position;
      });

      if (state.processingState == ProcessingState.completed) {
        playNext();
      } else if (state.processingState == ProcessingState.ready &&
          !state.playing) {
        updateTrackPosition(); // Update the position when the player stops
      }

      if (state.playing) {
        FFAppState().currentURL = widget.musicUrls[currentSongIndex];
      }
    });

    audioPlayer.positionStream.listen((position) {
      setState(() {
        currentPosition = position;
        FFAppState().currentTrackPosition = position.inMilliseconds.toDouble();
      });

      if (selectedTimer != null && currentPosition >= selectedTimer!) {
        audioPlayer.pause();
        setState(() {
          selectedTimer = null;
        });
      }
    });

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    // _fadeAnimation = CurvedAnimation(
    //   parent: _animationController,
    //    curve: Curves.easeIn,
    //  );

    _animationController.forward();
  }

  void updateTrackPosition() {
    // Update the AppState with the current track position
    FFAppState().currentTrackPosition =
        currentPosition.inMilliseconds.toDouble();
  }

  void updatePlayerState() {
    audioPlayer.play();
  }

  @override
  void dispose() {
    _appStatePollingTimer?.cancel(); // Cancel the timer
    //audioPlayer.dispose();
    _animationController.dispose();
    if (countdownTimer != null) {
      countdownTimer!.cancel();
    }
    super.dispose();
  }

  void seekTo(Duration position) {
    audioPlayer.seek(position);
  }

  void updatePosition(double value) {
    final newPosition = Duration(milliseconds: value.toInt());
    seekTo(newPosition); // Complete the method call by passing newPosition
  }

  void playPause() {
    if (isPlaying) {
      audioPlayer.pause(); // Pause if already playing
    } else {
      //stopAudioPlayback(); // Stop any other audio that might be playing
      audioPlayer.play(); // Start playing the audio
    }
  }

  void skip(Duration duration) {
    final newPosition = currentPosition + duration;
    if (newPosition < Duration.zero) {
      seekTo(Duration.zero);
    } else if (newPosition > totalDuration) {
      seekTo(totalDuration);
    } else {
      seekTo(newPosition);
    }
  }

  void playPrevious() {
    if (currentSongIndex > 0) {
      currentSongIndex--;
    } else {
      currentSongIndex = widget.musicUrls.length - 1;
    }
    audioPlayer.setUrl(widget.musicUrls[currentSongIndex]);
    audioPlayer.play();
  }

  void playNext() {
    if (isShuffling) {
      currentSongIndex = _getRandomIndex();
    } else {
      if (currentSongIndex < widget.musicUrls.length - 1) {
        currentSongIndex++;
      } else {
        currentSongIndex = 0;
      }
    }
    audioPlayer.setUrl(widget.musicUrls[currentSongIndex]);
    audioPlayer.play();
  }

  int _getRandomIndex() {
    final random = Random();
    int randomIndex = currentSongIndex;
    while (randomIndex == currentSongIndex) {
      randomIndex = random.nextInt(widget.musicUrls.length);
    }
    return randomIndex;
  }

  void setTimer(Duration duration) {
    setState(() {
      selectedTimer = duration;
      if (duration == Duration.zero) {
        audioPlayer.pause(); // Pause the player if the selected timer is
      }
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              thumbShape: RoundSliderThumbShape(
                  enabledThumbRadius: 0.0), // Adjust the thumb size here
            ),
            child: Slider(
              value: currentPosition.inMilliseconds.toDouble(),
              min: 0,
              max: totalDuration.inMilliseconds.toDouble(),
              onChanged: (double value) {
                setState(() {
                  updatePosition(
                      value); // Assuming updatePosition is a method that handles slider position changes
                });
              },
              activeColor: widget.sliderActiveColor,
              inactiveColor: widget.sliderInactiveColor,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${currentPosition.inMinutes}:${(currentPosition.inSeconds % 60).toString().padLeft(2, '0')}',
                style: TextStyle(color: widget.playbackDurationTextColor),
              ),
              Text(
                '${totalDuration.inMinutes}:${(totalDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                style: TextStyle(color: widget.playbackDurationTextColor),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () => skip(Duration(seconds: -10)),
                icon: widget.backwardIconPath,
                color: widget.backwardIconColor,
              ),
              IconButton(
                onPressed: playPrevious,
                icon: widget.previousIconPath,
                color: widget.previousIconColor,
              ),
              IconButton(
                onPressed: playPause,
                icon: isPlaying ? widget.pauseIconPath : widget.playIconPath,
                color: isPlaying ? widget.pauseIconColor : widget.playIconColor,
              ),
              IconButton(
                onPressed: playNext,
                icon: widget.nextIconPath,
                color: widget.nextIconColor,
              ),
              IconButton(
                onPressed: () => skip(Duration(seconds: 10)),
                icon: widget.forwardIconPath,
                color: widget.forwardIconColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
