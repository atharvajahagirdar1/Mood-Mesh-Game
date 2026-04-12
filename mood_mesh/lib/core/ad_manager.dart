import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io' show Platform;

class AdManager {
  static final AdManager instance = AdManager._init();
  AdManager._init();

  RewardedAd? _rewardedAd;
  bool isAdLoaded = false;

  // Test Ad Unit IDs provided by Google
  final String _androidRewardedId = 'ca-app-pub-3940256099942544/5224354917';
  final String _iosRewardedId = 'ca-app-pub-3940256099942544/1712485313';

  void loadRewardedAd() {
    String adUnitId = Platform.isAndroid ? _androidRewardedId : _iosRewardedId;

    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          isAdLoaded = true;
        },
        onAdFailedToLoad: (error) {
          isAdLoaded = false;
          _rewardedAd = null;
        },
      ),
    );
  }

  void showRewardedAd(Function onRewardEarned) {
    if (_rewardedAd != null && isAdLoaded) {
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          onRewardEarned();
        },
      );
      
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          loadRewardedAd(); // Load the next ad immediately
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          loadRewardedAd();
        },
      );
    } else {
      loadRewardedAd();
    }
  }
}
