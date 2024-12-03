import Flutter
import UIKit
//import FirebaseCore
//import FirebaseCore
//import FirebaseCrashlytics


@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      
      // This initializes Firebase
//      FirebaseApp.configure()
      
      // Optional: Enable Crashlytics
//      Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true) // Enable Crashlytics collection
      
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
      
      
  }
}
