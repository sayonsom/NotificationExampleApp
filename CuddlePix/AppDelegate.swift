

import UIKit
import UserNotifications

let userNotificationReceivedNotificationName = Notification.Name("com.ailienspace.usernotifs.userNotificationReceived")
let newCuddlePixCategoryName = "newCuddlePix"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
    UNUserNotificationCenter.current().delegate = self
    configureUserNotifications()
    application.registerForRemoteNotifications()
    return true
  }
  
  func configureUserNotifications() {
    let starAction = UNNotificationAction(identifier:
      "star", title: "Ya this Felt better!", options: [])
    let category =
      UNNotificationCategory(identifier: newCuddlePixCategoryName,
                             actions: [starAction],
                             intentIdentifiers: [],
                             options: [])
    
    UNUserNotificationCenter.current()
      .setNotificationCategories([category])
  }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler:
    @escaping (UNNotificationPresentationOptions) -> Void) {
    NotificationCenter.default.post(name:userNotificationReceivedNotificationName, object: .none)
    
    completionHandler(.alert)
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler
    completionHandler: @escaping () -> Void) {
    print("Response received for \(response.actionIdentifier)")
    completionHandler()
  }
}

extension AppDelegate {
  func application(_ application: UIApplication,
                   didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("Registration for remote notifications failed")
    print(error.localizedDescription)
  }
  
  func application(_ application: UIApplication,
                   didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    print("Registered with device token: \(deviceToken.hexString)")
  }
}
