// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '../widgets/advance_music_player.dart';

import 'package:just_audio/just_audio.dart';

Future<void> stopAudio() async {
  await AudioPlayerSingleton().audioPlayer.stop();
}
//bool isPlaying = false;
//Future<void> stopAudio() async {
// if (isPlaying) {
//   // If the audio is playing, then pause it
//   AudioPlayerSingleton().audioPlayer.pause();
//   isPlaying = false; // Update the state to indicate that the audio is paused
// } else {
//   // If the audio is not playing (i.e., paused or stopped), then stop it
//   AudioPlayerSingleton().audioPlayer.play();
//   isPlaying =
//       true; // Ensure the state is set to indicate that the audio is not playing
//  }
//}
