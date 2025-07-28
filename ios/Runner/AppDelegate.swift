import UIKit
import Flutter
import Firebase
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate, MessagingDelegate {

  var flutterViewController: FlutterViewController!

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    UNUserNotificationCenter.current().delegate = self
    Messaging.messaging().delegate = self

    // UINavigationController 안에 있는 FlutterViewController 가져오기
    if let navController = window?.rootViewController as? UINavigationController,
       let flutterVC = navController.children.first as? FlutterViewController {
      self.flutterViewController = flutterVC
    } else if let flutterVC = window?.rootViewController as? FlutterViewController {
      self.flutterViewController = flutterVC
    } else {
      fatalError("❌ Could not find FlutterViewController in rootViewController hierarchy.")
    }

    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // 플러그인 위임 처리
  override func registrar(forPlugin pluginKey: String) -> FlutterPluginRegistrar? {
    return flutterViewController?.registrar(forPlugin: pluginKey)
  }

  override func hasPlugin(_ pluginKey: String) -> Bool {
    return flutterViewController?.hasPlugin(pluginKey) ?? false
  }

  override func valuePublished(byPlugin pluginKey: String) -> NSObject? {
    return flutterViewController?.valuePublished(byPlugin: pluginKey)
  }

  // FCM 토큰 수신
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("🔔 FCM Token: \(fcmToken ?? "")")
  }
}