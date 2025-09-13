import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
       let dict = NSDictionary(contentsOfFile: path),
       let key = dict["GOOGLE_MAPS_API_KEY"] as? String {
      GMSServices.provideAPIKey(key)
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
