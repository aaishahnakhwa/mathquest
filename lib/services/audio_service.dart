import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioTrackInfo {
  final String id;
  final String title;
  final String subtitle;
  final String iconEmoji;
  final String assetPath;

  const AudioTrackInfo({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconEmoji,
    required this.assetPath,
  });
}

class AudioService extends ChangeNotifier {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;

  AudioService._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _isMusicEnabled = true;
  bool _isSoundFxEnabled = true;
  double _musicVolume = 0.35;
  double _soundFxVolume = 0.70;
  String _selectedTrackId = 'piano';
  bool _isInitialized = false;
  bool _isPlaying = false;

  static const List<AudioTrackInfo> availableTracks = [
    AudioTrackInfo(
      id: 'piano',
      title: 'Soft Piano',
      subtitle: 'Calm & ambient classical piano',
      iconEmoji: '🎹',
      assetPath: 'audio/soft_piano_bgm.wav',
    ),
    AudioTrackInfo(
      id: 'lofi',
      title: 'Lo-Fi Chill',
      subtitle: 'Warm study beats & rhodes keys',
      iconEmoji: '🎧',
      assetPath: 'audio/lofi_chill_bgm.wav',
    ),
    AudioTrackInfo(
      id: 'zen',
      title: 'Zen Acoustic',
      subtitle: 'Serene harp & meditative soundscape',
      iconEmoji: '🍃',
      assetPath: 'audio/zen_acoustic_bgm.wav',
    ),
  ];

  bool get isMusicEnabled => _isMusicEnabled;
  bool get isSoundFxEnabled => _isSoundFxEnabled;
  double get musicVolume => _musicVolume;
  double get soundFxVolume => _soundFxVolume;
  String get selectedTrackId => _selectedTrackId;
  bool get isPlaying => _isPlaying;

  AudioTrackInfo get currentTrack {
    return availableTracks.firstWhere(
      (t) => t.id == _selectedTrackId,
      orElse: () => availableTracks.first,
    );
  }

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _isMusicEnabled = prefs.getBool('is_music_enabled') ?? true;
      _isSoundFxEnabled = prefs.getBool('is_sound_fx_enabled') ?? true;
      _musicVolume = prefs.getDouble('music_volume') ?? 0.35;
      _soundFxVolume = prefs.getDouble('sound_fx_volume') ?? 0.70;
      _selectedTrackId = prefs.getString('selected_track_id') ?? 'piano';

      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.setVolume(_musicVolume);

      _isInitialized = true;
      notifyListeners();

      if (_isMusicEnabled) {
        startBGM();
      }
    } catch (e) {
      debugPrint('Error initializing AudioService: $e');
    }
  }

  Future<void> startBGM() async {
    if (!_isMusicEnabled) return;

    try {
      await _bgmPlayer.setVolume(_musicVolume);
      await _bgmPlayer.play(AssetSource(currentTrack.assetPath));
      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error playing background music: $e');
    }
  }

  Future<void> switchTrack(String trackId) async {
    if (_selectedTrackId == trackId) return;

    _selectedTrackId = trackId;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_track_id', _selectedTrackId);

      await _bgmPlayer.stop();
      if (_isMusicEnabled) {
        await startBGM();
      }
    } catch (e) {
      debugPrint('Error switching music track: $e');
    }
  }

  Future<void> pauseBGM() async {
    try {
      await _bgmPlayer.pause();
      _isPlaying = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error pausing BGM: $e');
    }
  }

  Future<void> resumeBGM() async {
    if (!_isMusicEnabled) return;
    try {
      await _bgmPlayer.resume();
      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      startBGM();
    }
  }

  Future<void> stopBGM() async {
    try {
      await _bgmPlayer.stop();
      _isPlaying = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error stopping BGM: $e');
    }
  }

  Future<void> toggleMusic() async {
    _isMusicEnabled = !_isMusicEnabled;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_music_enabled', _isMusicEnabled);

      if (_isMusicEnabled) {
        await startBGM();
      } else {
        await pauseBGM();
      }
    } catch (e) {
      debugPrint('Error toggling music: $e');
    }
  }

  Future<void> toggleSoundFx() async {
    _isSoundFxEnabled = !_isSoundFxEnabled;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_sound_fx_enabled', _isSoundFxEnabled);
    } catch (e) {
      debugPrint('Error toggling SFX: $e');
    }
  }

  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);
    notifyListeners();

    try {
      await _bgmPlayer.setVolume(_musicVolume);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('music_volume', _musicVolume);
    } catch (e) {
      debugPrint('Error setting music volume: $e');
    }
  }

  Future<void> setSoundFxVolume(double volume) async {
    _soundFxVolume = volume.clamp(0.0, 1.0);
    notifyListeners();

    try {
      await _sfxPlayer.setVolume(_soundFxVolume);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('sound_fx_volume', _soundFxVolume);
    } catch (e) {
      debugPrint('Error setting sound fx volume: $e');
    }
  }

  @override
  void dispose() {
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }
}
