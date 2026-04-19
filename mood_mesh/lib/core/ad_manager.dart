import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io' show Platform;

class AdManager {
  static final AdManager instance = AdManager._init();
  AdManager._init();

  RewardedAd? _rewardedAd;
  bool isAdLoaded = false;
  
  InterstitialAd? _interstitialAd;
  bool isInterstitialLoaded = false;

  final String _androidRewardedId = 'ca-app-pub-3940256099942544/5224354917';
  final String _iosRewardedId = 'ca-app-pub-3940256099942544/1712485313';
  
  final String _androidInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  final String _iosInterstitialId = 'ca-app-pub-3940256099942544/4411468910';

  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: Platform.isAndroid ? _androidRewardedId : _iosRewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) { _rewardedAd = ad; isAdLoaded = true; },
        onAdFailedToLoad: (error) { isAdLoaded = false; _rewardedAd = null; },
      ),
    );
  }

  void showRewardedAd(Function onRewardEarned) {
    if (_rewardedAd != null && isAdLoaded) {
      _rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) => onRewardEarned());
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) { ad.dispose(); loadRewardedAd(); },
        onAdFailedToShowFullScreenContent: (ad, error) { ad.dispose(); loadRewardedAd(); },
      );
    } else {
      loadRewardedAd();
    }
  }

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: Platform.isAndroid ? _androidInterstitialId : _iosInterstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) { _interstitialAd = ad; isInterstitialLoaded = true; },
        onAdFailedToLoad: (error) { _interstitialAd = null; isInterstitialLoaded = false; }
      )
    );
  }

  void showInterstitialIfReady() {
    if (_interstitialAd != null && isInterstitialLoaded) {
      _interstitialAd!.show();
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) { ad.dispose(); loadInterstitialAd(); },
        onAdFailedToShowFullScreenContent: (ad, err) { ad.dispose(); loadInterstitialAd(); }
      );
    } else {
      loadInterstitialAd();
    }
  }
}

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});
  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  final String _androidBannerId = 'ca-app-pub-3940256099942544/6300978111';
  final String _iosBannerId = 'ca-app-pub-3940256099942544/2934735716';

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: Platform.isAndroid ? _androidBannerId : _iosBannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) { setState(() => _isLoaded = true); }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded && _bannerAd != null) {
      return Container(
        color: Colors.transparent,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    return const SizedBox.shrink();
  }
}
