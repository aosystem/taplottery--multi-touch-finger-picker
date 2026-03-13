import 'dart:async';
import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:taplottery/l10n/app_localizations.dart';
import 'package:taplottery/const_value.dart';
import 'package:taplottery/parse_locale_tag.dart';
import 'package:taplottery/setting_page.dart';
import 'package:taplottery/model.dart';
import 'package:taplottery/tap_position.dart';
import 'package:taplottery/audio_play.dart';
import 'package:taplottery/play_mode.dart';
import 'package:taplottery/theme_color.dart';
import 'package:taplottery/ad_banner_widget.dart';
import 'package:taplottery/ad_manager.dart';
import 'package:taplottery/loading_screen.dart';
import 'package:taplottery/theme_mode_number.dart';
import 'package:taplottery/main.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});
  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> with SingleTickerProviderStateMixin {
  late AdManager _adManager;
  late ThemeColor _themeColor;
  bool _isReady = false;
  bool _isFirst = true;
  //
  final AudioPlay _audioPlay = AudioPlay();
  int _countdownSubtraction = 0;
  double _screenWidth = 0;
  double _screenHeight = 0;
  double _bgImageSize = 0;
  double _bgImageAngle = 0;
  String _imageCountdownNumber = ConstValue.imageNumberNull;
  double _countdownScale = 3;
  double _countdownOpacity = 0;
  int _timerCount = 30;
  List<TapPosition> _tapPositions = [];
  TapPosition _lastTapPosition = TapPosition(0,0);
  PlayMode _playMode = PlayMode.ready;

  @override
  void initState() {
    super.initState();
    _initState();
  }

  void _initState() async {
    _adManager = AdManager();
    Timer.periodic(const Duration(milliseconds: (1000 ~/ 30)), (timer) {
      setState(() {
        _countdown();
        _bgImageAngle -= 0.002;
        if (_bgImageAngle < -314159265) {
          _bgImageAngle = 0;
        }
      });
    });
    if (mounted) {
      setState(() {
        _isReady = true;
      });
    }
  }

  @override
  void dispose() {
    _adManager.dispose();
    super.dispose();
  }

  Future<void> _onOpenSetting() async {
    final updated = await Navigator.push<bool>(context,MaterialPageRoute(builder: (_) => const SettingPage()));
    if (!mounted) {
      return;
    }
    if (updated == true) {
      final mainState = context.findAncestorStateOfType<MainAppState>();
      if (mainState != null) {
        mainState
          ..themeMode = ThemeModeNumber.numberToThemeMode(Model.themeNumber)
          ..locale = parseLocaleTag(Model.languageCode)
          ..setState(() {});
      }
      _isFirst = true;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_isReady == false) {
      return const LoadingScreen();
    }
    if (_isFirst) {
      _isFirst = false;
      _themeColor = ThemeColor(context: context);
    }
    final l = AppLocalizations.of(context)!;
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
    _bgImageSize = max(_screenWidth,_screenHeight);
    return Container(
      decoration: _decoration(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              color: _themeColor.mainForeColor,
              tooltip: l.setting,
              onPressed: _onOpenSetting,
            ),
            const SizedBox(width:10),
          ],
        ),
        body: SafeArea(
          child: Column(children:[
            Expanded(
              child: RawGestureDetector(
                gestures: {
                  MultiTapGestureRecognizer: GestureRecognizerFactoryWithHandlers<MultiTapGestureRecognizer>(
                    () => MultiTapGestureRecognizer(),
                      (MultiTapGestureRecognizer instance) {
                      instance.onTapDown = (pointer, details) {
                        _onTapDown(details);
                      };
                    },
                  ),
                },
                child: Stack(children:[
                  _background(),
                  Container(
                    alignment: Alignment.center,
                    child: Opacity(
                      opacity: _countdownOpacity,
                      child: Transform.scale(
                        scale: _countdownScale,
                        child: Image.asset(
                          _imageCountdownNumber,
                        ),
                      )
                    )
                  ),
                  Stack(children:_tapCircles()),
                ])
              )
            ),
          ])
        ),
        bottomNavigationBar: AdBannerWidget(adManager: _adManager),
      )
    );
  }

  Decoration _decoration() {
    return const BoxDecoration(
      image: DecorationImage(
        image: AssetImage(ConstValue.imageSpace1),
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _background() {
    if (Model.backgroundRotate) {
      return Transform.rotate(
        angle: _bgImageAngle,
        child: Transform.scale(
          scale: 2.6,
          child: Image.asset(
            ConstValue.imageBackGrounds[Model.backgroundImageNumber],
            width: _bgImageSize,
            height: _bgImageSize,
          ),
        ),
      );
    } else {
      return Image.asset(
        ConstValue.imageBackGrounds[Model.backgroundImageNumber],
        width: _bgImageSize,
        height: _bgImageSize,
        fit: BoxFit.cover,
      );
    }
  }

  List<Widget> _tapCircles() {
    if (_tapPositions.isEmpty) {
      return [Container()];
    }
    const double widthRatio = 0.3;
    List<Widget> circles = [];
    circles.add(Container());
    if (_playMode == PlayMode.judgeDraw) {
      TapPosition tapPosition = _tapPositions[0];
      Widget circle5 = Positioned(
        left: tapPosition.x - _screenWidth * widthRatio / 2,
        top: tapPosition.y - _screenWidth * widthRatio / 2,
        child: Transform.rotate(
          angle: _bgImageAngle * 35,
          child: Transform.scale(
            scale: 1 + (_bgImageAngle % 0.04 - 0.02).abs() * 20,
            child: Opacity(
              opacity: 0.5,
              child: SvgPicture.asset(
                ConstValue.imageFire,
                width: _screenWidth * widthRatio,
                height: _screenWidth * widthRatio,
              )
            )
          )
        )
      );
      circles.add(circle5);
    }
    if (_playMode == PlayMode.countdown || _playMode == PlayMode.judgeDraw) {
      for (TapPosition tapPosition in _tapPositions) {
        Widget circle1 = Positioned(
          left: tapPosition.x - _screenWidth * widthRatio / 2,
          top: tapPosition.y - _screenWidth * widthRatio / 2,
          child: Transform.rotate(
            angle: _bgImageAngle * 25,
            child: SvgPicture.asset(
              ConstValue.imageRing1,
              width: _screenWidth * widthRatio,
              height: _screenWidth * widthRatio,
            )
          )
        );
        Widget circle2 = Positioned(
          left: tapPosition.x - _screenWidth * widthRatio / 2,
          top: tapPosition.y - _screenWidth * widthRatio / 2,
          child: Transform.rotate(
            angle: _bgImageAngle * 60,
            child: SvgPicture.asset(
              ConstValue.imageRing2,
              width: _screenWidth * widthRatio,
              height: _screenWidth * widthRatio,
            )
          )
        );
        Widget circle3 = Positioned(
          left: tapPosition.x - _screenWidth * widthRatio / 2,
          top: tapPosition.y - _screenWidth * widthRatio / 2,
          child: Transform.rotate(
            angle: _bgImageAngle * -50,
            child: SvgPicture.asset(
              ConstValue.imageRing3,
              width: _screenWidth * widthRatio,
              height: _screenWidth * widthRatio,
            )
          )
        );
        Widget circle4 = Positioned(
          left: tapPosition.x - _screenWidth * widthRatio / 2,
          top: tapPosition.y - _screenWidth * widthRatio / 2,
          child: Transform.rotate(
            angle: _bgImageAngle * -100,
            child: SvgPicture.asset(
              ConstValue.imageRing4,
              width: _screenWidth * widthRatio,
              height: _screenWidth * widthRatio,
            )
          )
        );
        circles.add(circle1);
        circles.add(circle2);
        circles.add(circle3);
        circles.add(circle4);
      }
    }
    return circles;
  }

  void _onTapDown(TapDownDetails details) {
    if (_playMode == PlayMode.ready || _playMode == PlayMode.countdown) {
      _lastTapPosition = TapPosition(details.localPosition.dx.toInt(), details.localPosition.dy.toInt());
      _tapPositions.add(_lastTapPosition);
      _countdownSubtraction = Model.countdownTime;
      _timerCount = 30;
      _playMode = PlayMode.countdown;
      _audioPlay.play02();
    }
  }

  void _countdown() {
    if (_countdownSubtraction == 0) {
      if (_playMode == PlayMode.judgeStart) {
        _judge();
      }
      return;
    }
    _playMode = PlayMode.countdown;
    if (_tapPositions.isEmpty) {
      _tapPositions = [_lastTapPosition];
    }
    if (_timerCount == 30) {
      _imageCountdownNumber = ConstValue.imageNumbers[_countdownSubtraction];
    }
    _timerCount -= 1;
    if (_timerCount <= 0) {
      _timerCount = 30;
      _countdownSubtraction -= 1;
      if (_countdownSubtraction == 0) {
        _imageCountdownNumber = ConstValue.imageNumbers[0];
        _playMode = PlayMode.judgeStart;
      }
    }
    _countdownScale = 1 + (0.1 * (_timerCount / 30));
    if (_timerCount >= 20) {
      _countdownOpacity = (30 - _timerCount) / 10;
    } else if (_timerCount <= 5) {
      _countdownOpacity = _timerCount / 5;
    } else {
      _countdownOpacity = 1;
    }
  }

  void _judge() {
    if (_tapPositions.isEmpty) {
      _playMode = PlayMode.ready;
      return;
    }
    if (_playMode == PlayMode.judgeStart) {
      _playMode = PlayMode.judgeDraw;
      _tapPositions.shuffle();
      TapPosition choice = _tapPositions[0];
      _tapPositions = [choice];
      _audioPlay.play01();
      Future.delayed(Duration(seconds: Model.resultDisplayDuration), () {
        _tapPositions = [];
        _playMode = PlayMode.ready;
      });
    }
  }

}
