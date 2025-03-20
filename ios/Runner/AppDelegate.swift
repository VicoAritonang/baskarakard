import AppCenter
import AppCenterAnalytics
import AppCenterCrashes

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        AppCenter.start(withAppSecret: "wkwk12345", services: [
            Analytics.self,
            Crashes.self
        ])
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
