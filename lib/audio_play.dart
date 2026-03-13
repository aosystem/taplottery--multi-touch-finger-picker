import 'package:just_audio/just_audio.dart';

import 'package:taplottery/const_value.dart';
import 'package:taplottery/model.dart';

class AudioPlay {
  static final List<AudioPlayer> _player01 = [
    AudioPlayer(),
    AudioPlayer(),
    AudioPlayer(),
  ];
  static final List<AudioPlayer> _player02 = [
    AudioPlayer(),
    AudioPlayer(),
    AudioPlayer(),
    AudioPlayer(),
    AudioPlayer(),
    AudioPlayer(),
    AudioPlayer(),
    AudioPlayer(),
    AudioPlayer(),
  ];
  int _player01Ptr = 0;
  int _player02Ptr = 0;

  AudioPlay() {
    _constructor();
  }
  void _constructor() async {
    for (int i = 0; i < _player01.length; i++) {
      await _player01[i].setVolume(0);
      await _player01[i].setAsset(ConstValue.audioResult);
    }
    for (int i = 0; i < _player02.length; i++) {
      await _player02[i].setVolume(0);
      await _player02[i].setAsset(ConstValue.audioTap);
    }
  }
  void dispose() {
    for (int i = 0; i < _player01.length; i++) {
      _player01[i].dispose();
    }
    for (int i = 0; i < _player02.length; i++) {
      _player02[i].dispose();
    }
  }

  void play01() async {
    if (Model.soundVolume == 0) {
      return;
    }
    _player01Ptr += 1;
    if (_player01Ptr >= _player01.length) {
      _player01Ptr = 0;
    }
    await _player01[_player01Ptr].setVolume(Model.soundVolume * 0.7);
    await _player01[_player01Ptr].pause();
    await _player01[_player01Ptr].seek(Duration.zero);
    await _player01[_player01Ptr].play();
  }

  void play02() async {
    if (Model.soundVolume == 0) {
      return;
    }
    _player02Ptr += 1;
    if (_player02Ptr >= _player02.length) {
      _player02Ptr = 0;
    }
    await _player02[_player02Ptr].setVolume(Model.soundVolume);
    await _player02[_player02Ptr].pause();
    await _player02[_player02Ptr].seek(Duration.zero);
    await _player02[_player02Ptr].play();
  }

}
