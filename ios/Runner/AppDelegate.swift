import UIKit
import UserNotifications 
import Flutter
import Fabric
import Crashlytics
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 10.0, *) {
  UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
}
    GMSServices.provideAPIKey("AIzaSyCCQSVqWyZvbH6UWES32eNEKb7UGJ4MxbQ")
    Fabric.with([Crashlytics.self])
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
