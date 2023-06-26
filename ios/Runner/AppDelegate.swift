import UIKit
import Flutter
import UserNotifications

@available(iOS 14.0, *)
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let METHOD_CHANNEL_NAME = "test"
        let batteryChannel = FlutterMethodChannel(name: METHOD_CHANNEL_NAME, binaryMessenger: controller as! FlutterBinaryMessenger)
        batteryChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            switch call.method {
            case "startPush":
                let content = UNMutableNotificationContent()
                content.title = "通知のタイトルです"
                content.body = "通知の内容です"
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
                let request = UNNotificationRequest(identifier: "通知No.1", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request)
                
                let content2 = UNMutableNotificationContent()
                content2.title = "2通知のタイトルです"
                content2.body = "2通知の内容です"
                
                let trigger2 = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
                let request2 = UNNotificationRequest(identifier: "通知No.2", content: content2, trigger: trigger2)
                UNUserNotificationCenter.current().add(request2)
                batteryChannel.invokeMethod("callMe", arguments: nil)
                result(["says"])
            default:
                result(FlutterMethodNotImplemented)
            }
        })
        
        // 通知許可の取得
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]){
                (granted, _) in
                if granted{
                    UNUserNotificationCenter.current().delegate = self
                }
            }
        
        // 通知処理
        if let notification = launchOptions?[.remoteNotification] as? [String: Any] {
            NSLog("停止から復帰")
            NSLog(notification.description)
        }
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        NSLog("バックグラウンドタップ時")
        NSLog(response.notification.request.description)
        completionHandler()
    }
}
