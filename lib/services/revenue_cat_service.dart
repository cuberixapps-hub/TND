import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  static const String _androidApiKey = 'YOUR_REVENUECAT_ANDROID_API_KEY';
  static const String _iosApiKey = 'YOUR_REVENUECAT_IOS_API_KEY';

  static const String entitlementId = 'tod_premium';

  static const String offeringOnboarding = 'tod_onboarding';
  static const String offeringModeGate = 'tod_mode_gate';
  static const String offeringSessionLimit = 'tod_session_limit';
  static const String offeringCustom = 'tod_custom';
  static const String offeringPostgame = 'tod_postgame';
  static const String offeringSettings = 'tod_settings';

  bool _isInitialized = false;

  bool get isConfigured => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    if (_androidApiKey.contains('YOUR_') || _iosApiKey.contains('YOUR_')) {
      debugPrint(
        '⚠️ RevenueCat API keys are placeholders — skipping Purchases.configure. '
        'Set real keys in revenue_cat_service.dart.',
      );
      return;
    }

    try {
      await Purchases.setLogLevel(
        kDebugMode ? LogLevel.debug : LogLevel.info,
      );

      PurchasesConfiguration configuration;
      if (Platform.isAndroid) {
        configuration = PurchasesConfiguration(_androidApiKey);
      } else if (Platform.isIOS) {
        configuration = PurchasesConfiguration(_iosApiKey);
      } else {
        throw UnsupportedError('Unsupported platform');
      }

      await Purchases.configure(configuration);
      _isInitialized = true;
      debugPrint('✅ RevenueCat initialized');
    } catch (e, st) {
      debugPrint('❌ RevenueCat initialize error: $e\n$st');
    }
  }

  Future<bool> isPremium() async {
    if (!_isInitialized) return false;
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
    } catch (e) {
      debugPrint('❌ RevenueCat isPremium error: $e');
      return false;
    }
  }

  Future<Offering?> getOffering(String offeringId) async {
    if (!_isInitialized) return null;
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.all[offeringId] ?? offerings.current;
    } catch (e) {
      debugPrint('❌ RevenueCat getOffering error: $e');
      return null;
    }
  }

  Future<bool> purchasePackage(Package package) async {
    if (!_isInitialized) return false;
    try {
      final customerInfo = await Purchases.purchasePackage(package);
      return customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('RevenueCat purchase cancelled');
      } else {
        debugPrint('❌ RevenueCat purchase error: $e');
      }
      return false;
    } catch (e) {
      debugPrint('❌ RevenueCat purchase error: $e');
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    if (!_isInitialized) return false;
    try {
      final customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.all[entitlementId]?.isActive ?? false;
    } catch (e) {
      debugPrint('❌ RevenueCat restore error: $e');
      return false;
    }
  }

  void addCustomerInfoUpdateListener(void Function(CustomerInfo) listener) {
    if (!_isInitialized) return;
    Purchases.addCustomerInfoUpdateListener(listener);
  }
}
