import 'package:just_audio/just_audio.dart';

final _player = AudioPlayer();

/// Single shared player instance for the whole app.
AudioPlayer get radioPlayer => _player;

Future<void> playRadioStation(String url) async {
  await _player.stop();
  await _player.setUrl(
    url,
    headers: const {
      'User-Agent':
          'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 Chrome/120.0 Mobile Safari/537.36',
    },
  );
  await _player.play();
}
