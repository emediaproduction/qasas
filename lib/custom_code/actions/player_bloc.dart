import 'package:bloc/bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'player_event.dart';
import 'player_state.dart' as custom;
import 'audio_player_singleton.dart';

class PlayerBloc extends Bloc<PlayerEvent, custom.PlayerState> {
  final AudioPlayer audioPlayer = AudioPlayerSingleton().audioPlayer;
  late ConcatenatingAudioSource _playlist;
  List<String> musicUrls;
  List<String> musicTitles = []; // Initialized to an empty list
  String initialUrl;
  String playlistImage;
  int currentTrackIndex = 0;
  double playbackSpeed = 1.0;

  PlayerBloc({
    required this.musicUrls,
    List<String>? titles,
    required this.initialUrl,
    required this.playlistImage,
  }) : super(custom.PlayerInitial()) {
    musicTitles = titles ?? []; // Ensure musicTitles is never null
    currentTrackIndex = musicUrls.indexOf(initialUrl);

    // Event handlers
    on<LoadTrack>(_onLoadTrack);
    on<PlayTrack>(_onPlayTrack);
    on<PauseTrack>(_onPauseTrack);
    on<StopTrack>(_onStopTrack);
    on<UpdatePosition>(_onUpdatePosition);
    on<ChangeTrack>(_onChangeTrack);
    on<SetPlaybackSpeed>(_onSetPlaybackSpeed);
    on<SkipForward>(_onSkipForward);
    on<SkipBackward>(_onSkipBackward);
    on<NextTrack>(_onNextTrack);
    on<PreviousTrack>(_onPreviousTrack);
    on<InitializePlayer>(
        _onInitializePlayer); // Added event handler for InitializePlayer
  }

  Future<void> initializePlayer({
    required String initialUrl,
    required List<String> urls,
    required List<String> titles,
    required String image,
  }) async {
    this.musicUrls = urls;
    this.musicTitles = titles;
    this.playlistImage = image;
    this.currentTrackIndex = musicUrls.indexOf(initialUrl);

    _loadAndPlayTrack(initialUrl); // Load and play the initial track;
  }

  Future<void> _loadAndPlayTrack(String url) async {
    try {
      var source = AudioSource.uri(Uri.parse(url), tag: playlistImage);
      _playlist = ConcatenatingAudioSource(children: [source]);
      await audioPlayer.setAudioSource(_playlist);
      await audioPlayer.play();
      _updateMediaItemAndState(url);
    } catch (e) {
      print('Error loading or playing track: $e');
    }
  }

  // Event handler for InitializePlayer
  void _onInitializePlayer(
      InitializePlayer event, Emitter<custom.PlayerState> emit) {
    // Your logic to handle player initialization
    // Update the PlayerBloc's fields with the event's data
    this.initialUrl = event.initialUrl;
    this.musicUrls = event.musicUrls;
    this.musicTitles = event.musicTitles;
    this.playlistImage = event.playlistImage;
    // Any additional initialization logic
  }

  // This function needs to emit states to reflect changes
  void _updateMediaItemAndState(String url, {bool paused = false}) {
    int index = musicUrls.indexOf(url);
    String title =
        index != -1 && index < musicTitles.length ? musicTitles[index] : '';

    AudioServiceBackground.setMediaItem(
        MediaItem(id: url, title: title, artUri: Uri.parse(playlistImage)));
    AudioServiceBackground.setState(
        playing: !paused,
        controls: paused
            ? [MediaControl.play, MediaControl.stop]
            : [MediaControl.pause, MediaControl.stop]);

    // Emitting the state is crucial here
    emit(paused
        ? custom.PlayerPaused(
            currentTrack: url,
            trackImageUrl: playlistImage,
            position: audioPlayer.position,
            totalDuration: audioPlayer.duration ?? Duration.zero)
        : custom.PlayerPlaying(
            currentTrack: url,
            trackImageUrl: playlistImage,
            position: audioPlayer.position,
            totalDuration: audioPlayer.duration ?? Duration.zero));
  }

  void _onLoadTrack(LoadTrack event, Emitter<custom.PlayerState> emit) async {
    var source = AudioSource.uri(Uri.parse(event.url), tag: event.imageUrl);
    _playlist = ConcatenatingAudioSource(children: [source]);
    await audioPlayer.setAudioSource(_playlist);
    currentTrackIndex = 0; // Assuming this is the first track
    _updateMediaItemAndState(event.url);
  }

  void _onPlayTrack(PlayTrack event, Emitter<custom.PlayerState> emit) async {
    await audioPlayer.play();
    _updateMediaItemAndState(musicUrls[currentTrackIndex]);
  }

  void _onPauseTrack(PauseTrack event, Emitter<custom.PlayerState> emit) {
    audioPlayer.pause();
    _updateMediaItemAndState(musicUrls[currentTrackIndex], paused: true);
  }

  void _onStopTrack(StopTrack event, Emitter<custom.PlayerState> emit) {
    audioPlayer.stop();
    emit(custom.PlayerStopped());
  }

  void _onUpdatePosition(
      UpdatePosition event, Emitter<custom.PlayerState> emit) {
    audioPlayer.seek(event.position);
    _updateMediaItemAndState(musicUrls[currentTrackIndex]);
  }

  void _onChangeTrack(
      ChangeTrack event, Emitter<custom.PlayerState> emit) async {
    await audioPlayer.setUrl(event.url);
    currentTrackIndex = musicUrls.indexOf(event.url);
    _updateMediaItemAndState(event.url);
  }

  void _onSetPlaybackSpeed(
      SetPlaybackSpeed event, Emitter<custom.PlayerState> emit) {
    audioPlayer.setSpeed(event.speed);
    _updateMediaItemAndState(musicUrls[currentTrackIndex]);
  }

  void _onSkipForward(SkipForward event, Emitter<custom.PlayerState> emit) {
    final newPosition = audioPlayer.position + Duration(seconds: event.seconds);
    audioPlayer.seek(newPosition);
    _updateMediaItemAndState(musicUrls[currentTrackIndex]);
  }

  void _onSkipBackward(SkipBackward event, Emitter<custom.PlayerState> emit) {
    final newPosition = audioPlayer.position - Duration(seconds: event.seconds);
    audioPlayer.seek(newPosition);
    _updateMediaItemAndState(musicUrls[currentTrackIndex]);
  }

  void _onNextTrack(NextTrack event, Emitter<custom.PlayerState> emit) async {
    currentTrackIndex = (currentTrackIndex + 1) % musicUrls.length;
    String nextTrackUrl = musicUrls[currentTrackIndex];
    await audioPlayer.setUrl(nextTrackUrl);
    _updateMediaItemAndState(nextTrackUrl);
  }

  void _onPreviousTrack(
      PreviousTrack event, Emitter<custom.PlayerState> emit) async {
    currentTrackIndex =
        currentTrackIndex > 0 ? currentTrackIndex - 1 : musicUrls.length - 1;
    String previousTrackUrl = musicUrls[currentTrackIndex];
    await audioPlayer.setUrl(previousTrackUrl);
    _updateMediaItemAndState(previousTrackUrl);
  }
}
