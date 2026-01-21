import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../monitoring/logging_service.dart';

/// Result of presenting a paywall to the user.
///
/// Maps to RevenueCat's PaywallResult for easier handling.
enum ZeyraPaywallResult {
  /// User purchased a subscription
  purchased,
  /// User restored a previous purchase
  restored,
  /// User dismissed the paywall without purchasing
  cancelled,
  /// An error occurred while presenting the paywall
  error,
}

/// Service for managing in-app purchases via RevenueCat.
///
/// Handles all subscription logic including:
/// - SDK initialization
/// - Fetching available offerings
/// - Processing purchases
/// - Checking entitlement status
/// - Restoring purchases
/// - Linking customers to auth users
/// - Presenting paywalls and customer center
///
/// **Important**: Do not store subscription status locally.
/// Always query RevenueCat for current entitlement status.
class PaymentService {
  final LoggingService _logger;

  /// RevenueCat entitlement identifier for Zeyra premium access.
  ///
  /// Must match the entitlement ID configured in RevenueCat dashboard.
  static const String entitlementId = 'Zeyra';

  /// Product identifiers for subscription offerings.
  ///
  /// Must match the product IDs configured in App Store Connect / Google Play Console.
  static const String productMonthly = 'monthly';
  static const String productYearly = 'yearly';

  /// Whether the SDK has been initialized
  bool _isInitialized = false;

  /// Stream controller for customer info updates.
  ///
  /// Used for reactive UI updates when subscription status changes.
  final StreamController<CustomerInfo> _customerInfoController =
      StreamController<CustomerInfo>.broadcast();

  PaymentService(this._logger);

  /// Stream of customer info updates.
  ///
  /// Subscribe to this stream to reactively update UI when subscription status changes.
  Stream<CustomerInfo> get customerInfoStream => _customerInfoController.stream;

  /// Initialize RevenueCat SDK with platform-specific API keys.
  ///
  /// Must be called during app initialization (in DIGraph.initialize).
  /// [iosApiKey] - RevenueCat API key for iOS (App Store)
  /// [androidApiKey] - RevenueCat API key for Android (Play Store)
  Future<void> initialize({
    required String iosApiKey,
    required String androidApiKey,
  }) async {
    if (_isInitialized) {
      _logger.debug('PaymentService already initialized');
      return;
    }

    // Check if API key is available for current platform
    final apiKey = Platform.isIOS ? iosApiKey : androidApiKey;
    if (apiKey.isEmpty) {
      _logger.warning('RevenueCat API key not configured for ${Platform.operatingSystem}');
      return;
    }

    try {
      // Configure RevenueCat with platform-specific API key
      final configuration = PurchasesConfiguration(apiKey);

      await Purchases.configure(configuration);
      
      // Set up listener for customer info updates
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        _customerInfoController.add(customerInfo);
        _logger.debug('Customer info updated: ${customerInfo.entitlements.active.keys}');
      });

      _isInitialized = true;
      _logger.info('PaymentService initialized successfully');
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to initialize PaymentService',
        error: e,
        stackTrace: stackTrace,
      );
      // Don't rethrow - app should continue even if payments fail to initialize
    }
  }

  /// Check if RevenueCat SDK is initialized.
  bool get isInitialized => _isInitialized;

  /// Dispose resources.
  void dispose() {
    _customerInfoController.close();
  }

  // ---------------------------------------------------------------------------
  // Customer Management
  // ---------------------------------------------------------------------------

  /// Link RevenueCat customer to Supabase auth user.
  ///
  /// Should be called after successful authentication to ensure
  /// purchases are associated with the correct user account.
  Future<void> linkToAuthUser(String authId) async {
    _ensureInitialized();
    try {
      await Purchases.logIn(authId);
      _logger.info('Linked RevenueCat customer to auth user: $authId');
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to link RevenueCat customer',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get current customer info with entitlements.
  Future<CustomerInfo> getCustomerInfo() async {
    _ensureInitialized();
    try {
      return await Purchases.getCustomerInfo();
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to get customer info',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Log out current customer (on app sign out).
  Future<void> logout() async {
    _ensureInitialized();
    try {
      await Purchases.logOut();
      _logger.info('RevenueCat customer logged out');
    } catch (e) {
      _logger.warning('Failed to log out RevenueCat customer: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Entitlement Checking
  // ---------------------------------------------------------------------------

  /// Check if user has active Zeyra premium entitlement.
  ///
  /// This is the primary method for checking subscription status.
  /// Always use this instead of storing subscription status locally.
  Future<bool> hasZeyraEntitlement() async {
    _ensureInitialized();
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final hasEntitlement = customerInfo.entitlements.active.containsKey(entitlementId);
      _logger.debug('Zeyra entitlement check: $hasEntitlement');
      return hasEntitlement;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to check entitlement status',
        error: e,
        stackTrace: stackTrace,
      );
      // Default to false on error - user will see paywall
      return false;
    }
  }

  /// Check Zeyra entitlement from CustomerInfo (synchronous).
  ///
  /// Use when you already have CustomerInfo from a recent operation.
  bool hasZeyraEntitlementFromInfo(CustomerInfo customerInfo) {
    return customerInfo.entitlements.active.containsKey(entitlementId);
  }

  /// Legacy alias for backward compatibility.
  @Deprecated('Use hasZeyraEntitlement() instead')
  Future<bool> isPremium() => hasZeyraEntitlement();

  /// Legacy alias for backward compatibility.
  @Deprecated('Use hasZeyraEntitlementFromInfo() instead')
  bool isPremiumFromInfo(CustomerInfo customerInfo) =>
      hasZeyraEntitlementFromInfo(customerInfo);

  /// Get the expiration date of Zeyra entitlement (if any).
  Future<DateTime?> getEntitlementExpirationDate() async {
    _ensureInitialized();
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final entitlement = customerInfo.entitlements.active[entitlementId];
      if (entitlement == null) return null;

      final expirationDateStr = entitlement.expirationDate;
      if (expirationDateStr == null) return null;

      return DateTime.tryParse(expirationDateStr);
    } catch (e) {
      _logger.warning('Failed to get expiration date: $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Offerings & Products
  // ---------------------------------------------------------------------------

  /// Get available offerings (subscription products).
  ///
  /// Returns the current offerings configured in RevenueCat dashboard.
  Future<Offerings> getOfferings() async {
    _ensureInitialized();
    try {
      final offerings = await Purchases.getOfferings();
      _logger.debug('Fetched offerings: ${offerings.all.keys.join(', ')}');
      return offerings;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to fetch offerings',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get the current offering (default offering to show users).
  Future<Offering?> getCurrentOffering() async {
    final offerings = await getOfferings();
    return offerings.current;
  }

  /// Get monthly package from current offering.
  Future<Package?> getMonthlyPackage() async {
    final offering = await getCurrentOffering();
    return offering?.monthly;
  }

  /// Get annual (yearly) package from current offering.
  Future<Package?> getYearlyPackage() async {
    final offering = await getCurrentOffering();
    return offering?.annual;
  }

  // ---------------------------------------------------------------------------
  // Purchases
  // ---------------------------------------------------------------------------

  /// Purchase a package (subscription product).
  ///
  /// Returns CustomerInfo with updated entitlements after purchase.
  /// Throws PlatformException if purchase fails.
  Future<CustomerInfo> purchase(Package package) async {
    _ensureInitialized();
    try {
      _logger.info('Initiating purchase for package: ${package.identifier}');
      final result = await Purchases.purchasePackage(package);
      _logger.info('Purchase completed successfully');
      return result;
    } on PlatformException catch (e) {
      // RevenueCat throws PlatformException with error details
      final errorCode = parseErrorCode(e);
      final userCancelled = _didUserCancel(e);

      if (userCancelled) {
        _logger.info('Purchase cancelled by user');
      } else {
        _logger.warning(
          'Purchase failed: ${errorCode?.name ?? e.code} - ${e.message}',
        );
      }
      rethrow;
    } catch (e, stackTrace) {
      _logger.error(
        'Unexpected error during purchase',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Restore previous purchases.
  ///
  /// Useful for users who reinstall the app or switch devices.
  /// Returns CustomerInfo with restored entitlements.
  Future<CustomerInfo> restore() async {
    _ensureInitialized();
    try {
      _logger.info('Restoring purchases');
      final customerInfo = await Purchases.restorePurchases();
      _logger.info('Purchases restored successfully');
      return customerInfo;
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to restore purchases',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Paywalls (RevenueCat UI)
  // ---------------------------------------------------------------------------

  /// Present a RevenueCat paywall.
  ///
  /// Shows the paywall configured in RevenueCat dashboard.
  /// Returns the result of the paywall presentation.
  ///
  /// [offering] - Optional specific offering to show. If null, uses current offering.
  Future<ZeyraPaywallResult> presentPaywall({Offering? offering}) async {
    _ensureInitialized();
    try {
      _logger.info('Presenting paywall');
      
      final paywallResult = await RevenueCatUI.presentPaywall(
        offering: offering,
      );

      return _mapPaywallResult(paywallResult);
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to present paywall',
        error: e,
        stackTrace: stackTrace,
      );
      return ZeyraPaywallResult.error;
    }
  }

  /// Present a RevenueCat paywall if the user doesn't have the Zeyra entitlement.
  ///
  /// Checks entitlement first and only shows paywall if needed.
  /// Returns the result of the paywall presentation (or purchased if already entitled).
  Future<ZeyraPaywallResult> presentPaywallIfNeeded() async {
    _ensureInitialized();
    try {
      _logger.info('Presenting paywall if needed');
      
      final paywallResult = await RevenueCatUI.presentPaywallIfNeeded(entitlementId);

      return _mapPaywallResult(paywallResult);
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to present paywall',
        error: e,
        stackTrace: stackTrace,
      );
      return ZeyraPaywallResult.error;
    }
  }

  /// Map RevenueCat paywall result to our enum.
  ZeyraPaywallResult _mapPaywallResult(PaywallResult paywallResult) {
    switch (paywallResult) {
      case PaywallResult.purchased:
        return ZeyraPaywallResult.purchased;
      case PaywallResult.restored:
        return ZeyraPaywallResult.restored;
      case PaywallResult.notPresented:
      case PaywallResult.cancelled:
        return ZeyraPaywallResult.cancelled;
      case PaywallResult.error:
        return ZeyraPaywallResult.error;
    }
  }

  /// Get a paywall widget to embed in your own UI.
  ///
  /// Use this when you want to embed the paywall in a custom screen
  /// rather than presenting it modally.
  ///
  /// [offering] - Optional specific offering to show. If null, uses current offering.
  Widget getPaywallWidget({Offering? offering}) {
    return PaywallView(
      offering: offering,
    );
  }

  // ---------------------------------------------------------------------------
  // Customer Center
  // ---------------------------------------------------------------------------

  /// Present the RevenueCat Customer Center.
  ///
  /// Shows a UI for users to manage their subscriptions,
  /// including viewing active subscriptions and requesting refunds.
  Future<void> presentCustomerCenter() async {
    _ensureInitialized();
    try {
      _logger.info('Presenting Customer Center');
      await RevenueCatUI.presentCustomerCenter();
      _logger.info('Customer Center dismissed');
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to present Customer Center',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Ensure SDK is initialized before operations.
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'PaymentService not initialized. Call initialize() first.',
      );
    }
  }

  /// Get user-friendly error message for purchase errors.
  static String getPurchaseErrorMessage(PurchasesErrorCode errorCode) {
    switch (errorCode) {
      case PurchasesErrorCode.purchaseCancelledError:
        return 'Purchase was cancelled';
      case PurchasesErrorCode.networkError:
        return 'Network error. Please check your connection.';
      case PurchasesErrorCode.productNotAvailableForPurchaseError:
        return 'This product is not available for purchase';
      case PurchasesErrorCode.purchaseNotAllowedError:
        return 'Purchases are not allowed on this device';
      case PurchasesErrorCode.purchaseInvalidError:
        return 'The purchase was invalid';
      case PurchasesErrorCode.storeProblemError:
        return 'There was a problem with the app store. Please try again.';
      case PurchasesErrorCode.receiptAlreadyInUseError:
        return 'This receipt is already in use by another user';
      default:
        return 'Purchase failed. Please try again.';
    }
  }

  /// Parse PurchasesErrorCode from a PlatformException.
  ///
  /// RevenueCat throws PlatformException with error details in the `details` map.
  /// Returns null if the error code cannot be parsed.
  static PurchasesErrorCode? parseErrorCode(PlatformException exception) {
    final details = exception.details;
    if (details is! Map) return null;

    // Try 'readableErrorCode' first (more reliable)
    final readableCode = details['readableErrorCode'] as String?;
    if (readableCode != null) {
      return _errorCodeFromString(readableCode);
    }

    // Fall back to numeric code
    final code = details['code'] as int?;
    if (code != null) {
      return _errorCodeFromInt(code);
    }

    return null;
  }

  /// Check if the user cancelled the purchase from a PlatformException.
  static bool _didUserCancel(PlatformException exception) {
    final details = exception.details;
    if (details is Map) {
      return details['userCancelled'] == true;
    }
    return false;
  }

  /// Get user-friendly error message from a PlatformException.
  ///
  /// Extracts the error code and returns an appropriate message.
  static String getErrorMessageFromException(PlatformException exception) {
    // Check if user cancelled
    if (_didUserCancel(exception)) {
      return 'Purchase was cancelled';
    }

    // Try to parse the error code
    final errorCode = parseErrorCode(exception);
    if (errorCode != null) {
      return getPurchaseErrorMessage(errorCode);
    }

    // Fall back to the exception message if available
    if (exception.message != null && exception.message!.isNotEmpty) {
      return exception.message!;
    }

    return 'Purchase failed. Please try again.';
  }

  /// Map readable error code string to PurchasesErrorCode enum.
  static PurchasesErrorCode? _errorCodeFromString(String code) {
    // RevenueCat uses PascalCase for readableErrorCode
    switch (code) {
      case 'PurchaseCancelledError':
        return PurchasesErrorCode.purchaseCancelledError;
      case 'NetworkError':
        return PurchasesErrorCode.networkError;
      case 'ProductNotAvailableForPurchaseError':
        return PurchasesErrorCode.productNotAvailableForPurchaseError;
      case 'PurchaseNotAllowedError':
        return PurchasesErrorCode.purchaseNotAllowedError;
      case 'PurchaseInvalidError':
        return PurchasesErrorCode.purchaseInvalidError;
      case 'StoreProblemError':
        return PurchasesErrorCode.storeProblemError;
      case 'ReceiptAlreadyInUseError':
        return PurchasesErrorCode.receiptAlreadyInUseError;
      case 'UnknownError':
        return PurchasesErrorCode.unknownError;
      default:
        return null;
    }
  }

  /// Map numeric error code to PurchasesErrorCode enum.
  static PurchasesErrorCode? _errorCodeFromInt(int code) {
    // RevenueCat error codes (from SDK documentation)
    switch (code) {
      case 1:
        return PurchasesErrorCode.purchaseCancelledError;
      case 2:
        return PurchasesErrorCode.storeProblemError;
      case 3:
        return PurchasesErrorCode.purchaseNotAllowedError;
      case 4:
        return PurchasesErrorCode.purchaseInvalidError;
      case 5:
        return PurchasesErrorCode.productNotAvailableForPurchaseError;
      case 6:
        return PurchasesErrorCode.productAlreadyPurchasedError;
      case 7:
        return PurchasesErrorCode.receiptAlreadyInUseError;
      case 10:
        return PurchasesErrorCode.networkError;
      default:
        return null;
    }
  }
}
