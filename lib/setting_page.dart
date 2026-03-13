import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_review/in_app_review.dart';

import 'package:taplottery/l10n/app_localizations.dart';
import 'package:taplottery/model.dart';
import 'package:taplottery/theme_color.dart';
import 'package:taplottery/ad_manager.dart';
import 'package:taplottery/ad_ump_status.dart';
import 'package:taplottery/ad_banner_widget.dart';
import 'package:taplottery/loading_screen.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late AdManager _adManager;
  late UmpConsentController _adUmp;
  AdUmpState _adUmpState = AdUmpState.initial;
  int _themeNumber = 0;
  String _languageCode = '';
  late ThemeColor _themeColor;
  final _inAppReview = InAppReview.instance;
  bool _isReady = false;
  bool _isFirst = true;
  //
  int _countdownTime = 5;
  int _resultDisplayDuration = 5;
  double _soundVolume = 0.0;
  int _backgroundImageNumber = 0;
  bool _backgroundRotate = false;

  @override
  void initState() {
    super.initState();
    _initState();
  }

  @override
  void dispose() {
    _adManager.dispose();
    super.dispose();
  }

  void _initState() async {
    _adManager = AdManager();
    _countdownTime = Model.countdownTime;
    _resultDisplayDuration = Model.resultDisplayDuration;
    _soundVolume = Model.soundVolume;
    _backgroundImageNumber = Model.backgroundImageNumber;
    _backgroundRotate = Model.backgroundRotate;
    _themeNumber = Model.themeNumber;
    _languageCode = Model.languageCode;
    //
    _adUmp = UmpConsentController();
    _refreshConsentInfo();
    //
    setState(() {
      _isReady = true;
    });
  }

  Future<void> _refreshConsentInfo() async {
    _adUmpState = await _adUmp.updateConsentInfo(current: _adUmpState);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _onTapPrivacyOptions() async {
    final err = await _adUmp.showPrivacyOptions();
    await _refreshConsentInfo();
    if (err != null && mounted) {
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l.cmpErrorOpeningSettings} ${err.message}')),
      );
    }
  }

  Future<void> _onApply() async {
    await Model.setCountdownTime(_countdownTime);
    await Model.setResultDisplayDuration(_resultDisplayDuration);
    await Model.setSoundVolume(_soundVolume);
    await Model.setBackgroundImageNumber(_backgroundImageNumber);
    await Model.setBackgroundRotate(_backgroundRotate);
    await Model.setThemeNumber(_themeNumber);
    await Model.setLanguageCode(_languageCode);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return LoadingScreen();
    }
    if (_isFirst) {
      _isFirst = false;
      _themeColor = ThemeColor(themeNumber: Model.themeNumber, context: context);
    }
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(l.setting),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child:IconButton(
              icon: const Icon(Icons.check),
              onPressed: _onApply,
            )
          ),
        ],
      ),
      body: SafeArea(
        child:Column(children:[
          Expanded(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 100),
                  child: Column(children: [
                    _buildCountdownTime(l),
                    _buildResultDisplayDuration(l),
                    _buildSoundVolume(l),
                    _buildBackgroundImageNumber(l),
                    _buildBackgroundRotate(l),
                    _buildTheme(l),
                    _buildLanguage(l),
                    _buildReview(l),
                    _buildCmp(l),
                    _buildUsage(l),
                  ]),
                ),
              ),
            ),
          ),
        ]),
      ),
      bottomNavigationBar: AdBannerWidget(adManager: _adManager),
    );
  }

  Widget _buildCountdownTime(AppLocalizations l) {
    return Card(
      margin: const EdgeInsets.only(left: 0, top: 12, right: 0, bottom: 0),
      color: _themeColor.cardColor,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
            child: Row(
              children: [
                Text(l.countdownTime),
                const Spacer(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Row(
              children: <Widget>[
                Text(_countdownTime.toStringAsFixed(0)),
                Expanded(
                  child: Slider(
                      value: _countdownTime.toDouble(),
                      min: 1,
                      max: 9,
                      divisions: 8,
                      label: _countdownTime.toString(),
                      onChanged: (double value) {
                        setState(() {
                          _countdownTime = value.toInt();
                        });
                      }
                  ),
                ),
              ],
            ),
          ),
        ],
      )
    );
  }

  Widget _buildResultDisplayDuration(AppLocalizations l) {
    return Card(
        margin: const EdgeInsets.only(left: 0, top: 12, right: 0, bottom: 0),
        color: _themeColor.cardColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: Row(
                children: [
                  Text(l.resultDisplayDuration),
                  const Spacer(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Row(
                children: <Widget>[
                  Text(_resultDisplayDuration.toStringAsFixed(0)),
                  Expanded(
                    child: Slider(
                        value: _resultDisplayDuration.toDouble(),
                        min: 1,
                        max: 9,
                        divisions: 8,
                        label: _resultDisplayDuration.toString(),
                        onChanged: (double value) {
                          setState(() {
                            _resultDisplayDuration = value.toInt();
                          });
                        }
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
    );
  }

  Widget _buildSoundVolume(AppLocalizations l) {
    return Card(
      margin: const EdgeInsets.only(left: 0, top: 12, right: 0, bottom: 0),
      color: _themeColor.cardColor,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
            child: Row(
              children: [
                Text(l.soundVolume),
                const Spacer(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Row(
              children: <Widget>[
                Text(_soundVolume.toStringAsFixed(1)),
                Expanded(
                  child: Slider(
                    value: _soundVolume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: _soundVolume.toStringAsFixed(1),
                    onChanged: (double value) {
                      setState(() {
                        _soundVolume = value;
                      });
                    }
                  ),
                ),
              ],
            ),
          ),
        ],
      )
    );
  }

  Widget _buildBackgroundImageNumber(AppLocalizations l) {
    return Card(
      margin: const EdgeInsets.only(left: 0, top: 12, right: 0, bottom: 0),
      color: _themeColor.cardColor,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
            child: Row(
              children: [
                Text(l.backgroundImageNumber),
                const Spacer(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Row(
              children: <Widget>[
                Text(_backgroundImageNumber.toStringAsFixed(0)),
                Expanded(
                  child: Slider(
                      value: _backgroundImageNumber.toDouble(),
                      min: 0,
                      max: 17,
                      divisions: 17,
                      label: _backgroundImageNumber.toString(),
                      onChanged: (double value) {
                        setState(() {
                          _backgroundImageNumber = value.toInt();
                        });
                      }
                  ),
                ),
              ],
            ),
          ),
        ],
      )
    );
  }

  Widget _buildBackgroundRotate(AppLocalizations l) {
    return Card(
        margin: const EdgeInsets.only(left: 0, top: 12, right: 0, bottom: 0),
        color: _themeColor.cardColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(l.backgroundRotate),
                  ),
                  Switch(
                    value: _backgroundRotate,
                    onChanged: (bool value) {
                      setState(() {
                        _backgroundRotate = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        )
    );
  }

  Widget _buildTheme(AppLocalizations l) {
    final TextTheme t = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(left: 0, top: 12, right: 0, bottom: 0),
      color: _themeColor.cardColor,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                l.theme,
                style: t.bodyMedium,
              ),
            ),
            DropdownButton<int>(
              value: _themeNumber,
              items: [
                DropdownMenuItem(value: 0, child: Text(l.systemSetting)),
                DropdownMenuItem(value: 1, child: Text(l.lightTheme)),
                DropdownMenuItem(value: 2, child: Text(l.darkTheme)),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _themeNumber = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguage(AppLocalizations l) {
    final Map<String,String> languageNames = {
      'af': 'af: Afrikaans',
      'ar': 'ar: العربية',
      'bg': 'bg: Български',
      'bn': 'bn: বাংলা',
      'bs': 'bs: Bosanski',
      'ca': 'ca: Català',
      'cs': 'cs: Čeština',
      'da': 'da: Dansk',
      'de': 'de: Deutsch',
      'el': 'el: Ελληνικά',
      'en': 'en: English',
      'es': 'es: Español',
      'et': 'et: Eesti',
      'fa': 'fa: فارسی',
      'fi': 'fi: Suomi',
      'fil': 'fil: Filipino',
      'fr': 'fr: Français',
      'gu': 'gu: ગુજરાતી',
      'he': 'he: עברית',
      'hi': 'hi: हिन्दी',
      'hr': 'hr: Hrvatski',
      'hu': 'hu: Magyar',
      'id': 'id: Bahasa Indonesia',
      'it': 'it: Italiano',
      'ja': 'ja: 日本語',
      'km': 'km: ខ្មែរ',
      'kn': 'kn: ಕನ್ನಡ',
      'ko': 'ko: 한국어',
      'lt': 'lt: Lietuvių',
      'lv': 'lv: Latviešu',
      'ml': 'ml: മലയാളം',
      'mr': 'mr: मराठी',
      'ms': 'ms: Bahasa Melayu',
      'my': 'my: မြန်မာ',
      'ne': 'ne: नेपाली',
      'nl': 'nl: Nederlands',
      'or': 'or: ଓଡ଼ିଆ',
      'pa': 'pa: ਪੰਜਾਬੀ',
      'pl': 'pl: Polski',
      'pt': 'pt: Português',
      'ro': 'ro: Română',
      'ru': 'ru: Русский',
      'si': 'si: සිංහල',
      'sk': 'sk: Slovenčina',
      'sr': 'sr: Српски',
      'sv': 'sv: Svenska',
      'sw': 'sw: Kiswahili',
      'ta': 'ta: தமிழ்',
      'te': 'te: తెలుగు',
      'th': 'th: ไทย',
      'tl': 'tl: Tagalog',
      'tr': 'tr: Türkçe',
      'uk': 'uk: Українська',
      'ur': 'ur: اردو',
      'uz': 'uz: Oʻzbekcha',
      'vi': 'vi: Tiếng Việt',
      'zh': 'zh: 中文',
      'zu': 'zu: isiZulu',
    };
    final TextTheme t = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(left: 0, top: 12, right: 0, bottom: 0),
      color: _themeColor.cardColor,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                l.language,
                style: t.bodyMedium,
              ),
            ),
            DropdownButton<String?>(
              value: _languageCode,
              items: [
                DropdownMenuItem(value: '', child: Text('Default')),
                ...languageNames.entries.map((entry) => DropdownMenuItem<String?>(
                  value: entry.key,
                  child: Text(entry.value),
                )),
              ],
              onChanged: (String? value) {
                setState(() {
                  _languageCode = value ?? '';
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReview(AppLocalizations l) {
    final TextTheme t = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(left: 0, top: 12, right: 0, bottom: 0),
      color: _themeColor.cardColor,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.reviewApp, style: t.bodyMedium),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  icon: Icon(Icons.open_in_new, size: 16),
                  label: Text(l.reviewStore, style: t.bodySmall),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 12),
                    side: BorderSide(color: Theme.of(context).colorScheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    await _inAppReview.openStoreListing(
                      appStoreId: 'YOUR_APP_STORE_ID',
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCmp(AppLocalizations l) {
    final TextTheme t = Theme.of(context).textTheme;
    final showButton = _adUmpState.privacyStatus == PrivacyOptionsRequirementStatus.required;
    String statusLabel = l.cmpCheckingRegion;
    IconData statusIcon = Icons.help_outline;
    switch (_adUmpState.privacyStatus) {
      case PrivacyOptionsRequirementStatus.required:
        statusLabel = l.cmpRegionRequiresSettings;
        statusIcon = Icons.privacy_tip_outlined;
        break;
      case PrivacyOptionsRequirementStatus.notRequired:
        statusLabel = l.cmpRegionNoSettingsRequired;
        statusIcon = Icons.check_circle_outline;
        break;
      case PrivacyOptionsRequirementStatus.unknown:
        statusLabel = l.cmpRegionCheckFailed;
        statusIcon = Icons.error_outline;
        break;
    }
    return Card(
      margin: const EdgeInsets.only(left: 0, top: 12, right: 0, bottom: 0),
      color: _themeColor.cardColor,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.cmpSettingsTitle,
              style: t.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l.cmpConsentDescription,
              style: t.bodySmall,
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Chip(
                    avatar: Icon(statusIcon, size: 18),
                    label: Text(statusLabel),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${l.cmpConsentStatusLabel} ${_adUmpState.consentStatus.localized(context)}',
                    style: t.bodySmall,
                  ),
                  if (showButton) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _adUmpState.isChecking
                          ? null
                          : _onTapPrivacyOptions,
                      icon: const Icon(Icons.settings),
                      label: Text(
                        _adUmpState.isChecking
                            ? l.cmpConsentStatusChecking
                            : l.cmpOpenConsentSettings,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _adUmpState.isChecking
                          ? null
                          : _refreshConsentInfo,
                      icon: const Icon(Icons.refresh),
                      label: Text(l.cmpRefreshStatus),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final message = l.cmpResetStatusDone;
                        await ConsentInformation.instance.reset();
                        await _refreshConsentInfo();
                        if (!mounted) {
                          return;
                        }
                        messenger.showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                      },
                      icon: const Icon(Icons.delete_sweep_outlined),
                      label: Text(l.cmpResetStatus),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsage(AppLocalizations l) {
    final TextTheme t = Theme.of(context).textTheme;
    return SizedBox(
        width: double.infinity,
        child: Card(
          margin: const EdgeInsets.only(left: 0, top: 12, right: 0, bottom: 0),
          color: _themeColor.cardColor,
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.usage1, style: t.bodySmall),
                const SizedBox(height: 12),
                Text(l.usage2, style: t.bodySmall),
                const SizedBox(height: 12),
                Text(l.usage3, style: t.bodySmall),
              ],
            ),
          ),
        )
    );
  }

}
