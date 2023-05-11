import 'package:pigeon/pigeon.dart';

// Regenerate the output files by running `dart run pigeon --input pigeons/push_api.dart`
@ConfigurePigeon(PigeonOptions(
  dartOut: '../push_platform_interface/lib/src/serialization/push_api.dart',
  dartTestOut: '../push_platform_interface/test/push_api_test.dart',
  // for iOS
  objcHeaderOut: '../push_ios/ios/Classes/serialization/PushApi.h',
  objcSourceOut: '../push_ios/ios/Classes/serialization/PushApi.m',
  // for macOS
  // objcHeaderOut: '../push_macos/macos/Classes/serialization/PushApi.h',
  // objcSourceOut: '../push_macos/macos/Classes/serialization/PushApi.m',
  objcOptions: ObjcOptions(prefix: "PU"),
  javaOut:
      '../push_android/android/src/main/java/uk/orth/push/serialization/PushApi.java',
  javaOptions: JavaOptions(package: 'uk.orth.push.serialization'),
))
// End of configuration

class RemoteMessage {
  Notification? notification;
  Map<String?, Object?>? data;
}

class Notification {
  String? title;
  String? body;
}

@HostApi()
abstract class PushHostApi {
  /// Returns null if it doesn't exist.
  /// See [PushFlutterApi.onNotificationTap] to understand why a RemoteMessage is not provided here.
  Map<String?, Object?>? getNotificationTapWhichLaunchedTerminatedApp();

  @async
  String getToken();

  void backgroundFlutterApplicationReady();

  void onListenToOnNewToken();

  void onCancelToOnNewToken();

  /// Pass true for the option you want permission to use
  /// Returns true if permission was granted.
  @async
  bool requestPermission(
    bool badge,
    bool sound,
    bool alert,
    bool carPlay,
    bool criticalAlert,
    bool provisional,
    bool providesAppNotificationSettings,
    bool announcement,
  );

  // iOS only
  @async
  UNNotificationSettings getNotificationSettings();

  // Android only
  @async
  bool areNotificationsEnabled();
}

@FlutterApi()
abstract class PushFlutterApi {
  void onMessage(RemoteMessage message);

  void onBackgroundMessage(RemoteMessage message);

  /// Unfortunately, the intent provided to the app when a user taps on a
  /// notification does not include notification's title or body.
  /// In this instance, it makes more sense to remove this useful functionality from iOS too.
  /// Only the data property on the RemoteMessage is returned to the user.
  /// This is effectively the lowest common denominator API.
  ///
  /// Hint: You can still include the title, body or other metadata in your
  /// data payload to identify what notification the user tapped on.
  void onNotificationTap(Map<String?, Object?> data);

  void onNewToken(String token);

  void onOpenNotificationSettings();
}

/// # iOS UN (UserNotification) symbols
///
/// Dart/Flutter translation of the iOS permissions API. In a future release,
/// we may replace this API with a consistent API for all platforms that require
/// permissions to show notifications to the user.

/// UNAuthorizationStatus: Constants indicating whether the app is allowed to
/// schedule notifications.
///
/// See the [Apple documentation](https://developer.apple.com/documentation/usernotifications/unnotificationsettings/1648391-authorizationstatus) for more information
enum UNAuthorizationStatus {
  notDetermined,
  denied,
  authorized,
  provisional,
  ephemeral
}

/// The type of notification the user will see
///
/// See the [Apple documentation](https://developer.apple.com/documentation/usernotifications/unalertstyle) for more information
enum UNAlertStyle { none, banner, alert }

/// The current configuration of a notification setting
///
/// See the [Apple documentation](https://developer.apple.com/documentation/usernotifications/unnotificationsetting) for more information
enum UNNotificationSetting { notSupported, disabled, enabled }

/// Conditions to show/reveal notification content to the user
///
/// See the [Apple documentation](https://developer.apple.com/documentation/usernotifications/unshowpreviewssetting) for more information
enum UNShowPreviewsSetting { always, whenAuthenticated, never }

/// The object for reading notification-related settings and the authorization status of your app.
///
/// See the [Apple documentation](https://developer.apple.com/documentation/usernotifications/unnotificationsettings) for more information
class UNNotificationSettings {
  UNAuthorizationStatus? authorizationStatus;
  UNNotificationSetting? soundSetting;
  UNNotificationSetting? badgeSetting;
  UNNotificationSetting? alertSetting;
  UNNotificationSetting? notificationCenterSetting;
  UNNotificationSetting? lockScreenSetting;
  UNNotificationSetting? carPlaySetting;
  UNAlertStyle? alertStyle;
  UNShowPreviewsSetting? showPreviewsSetting;
  UNNotificationSetting? criticalAlertSetting;
  bool? providesAppNotificationSettings;
  UNNotificationSetting? announcementSetting;
}
