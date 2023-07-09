import UIKit
import Flutter
import UserNotifications
import Hydra

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
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        
        // 通知処理
        NSLog("停止から復帰")
        if let notification = launchOptions?[.remoteNotification] as? [String: Any] {
            NSLog(notification.description)
        }
        
        do {
            try Hydra.await(self.getNotifications())
        } catch {
            NSLog("エラーです")
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        NSLog("バックグラウンドタップ時")
        NSLog(response.notification.request.description)
        completionHandler()
    }
    
    // デバイストークンの取得
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NSLog("デバイストークンの取得")
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        NSLog("デバイストークン: \(token)")
    }
    
    // プッシュ通知の登録失敗時の処理
    override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NSLog("デバイストークンの取得に失敗しました: \(error.localizedDescription)")
    }
    
    // リモート通知を受け取った時の処理
    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        NSLog("リモート通知を受け取りました: \(userInfo)")
        
    }
    
    private func getNotifications() -> Promise<String> {
        return Promise<String> { resolve, _ , _ in
            NSLog("UNUserNotificationCenter")
            UNUserNotificationCenter.current().getDeliveredNotifications(completionHandler: { notifications in
                for notification in notifications {
                    let content = notification.request.content
                    NSLog(content.title)
                    NSLog(content.body)
                    NSLog(content.userInfo.description)
                    let aps = content.userInfo["aps"] as? [String:Any] ?? ["test": "仮"]
                    let test = aps["test"] as? String ?? "データなし"
                    NSLog(test)
                 }
                NSLog("exit")
                resolve("Success")
            })
        }
    }
}
