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

Future<void> navigateToPlayer(BuildContext context, String initialUrl,
    int initialIndex, String routeName) async {
  Navigator.of(context).pushNamed(
    routeName,
    arguments: {
      'initialUrl': initialUrl,
      'initialIndex': initialIndex,
    },
  );
}
