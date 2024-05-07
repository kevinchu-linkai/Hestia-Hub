//
//  HestiaHubApp.swift
//  HestiaHub
//
//  Created by 朱麟凱 on 4/28/24.
//
import UIKit
import SwiftUI
import UserNotifications

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound]) // Ensure notifications appear even when the app is active
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Customize navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.amethyst  // Set your custom color
        appearance.titleTextAttributes = [.foregroundColor: UIColor.daisy2]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.daisy2]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        UIView.appearance().tintColor = UIColor.cloud

        return true
    }
}


struct PressableButtonStyle: ButtonStyle {
    var defaultColor: Color = Color.cBlue
    var pressedColor: Color = Color.cSlate
    var height: CGFloat = 340
    var width: CGFloat = 10

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? pressedColor : defaultColor)
            .frame(width: width, height: height)
            .padding(.all,10)
            .background(configuration.isPressed ? defaultColor.opacity(0.5) : pressedColor.opacity(0.8))
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
    }
}

@main
struct HestiaHubApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let persistenceController = PersistenceController.shared
    
    init() {
            // Assign the notification center delegate
            UNUserNotificationCenter.current().delegate = appDelegate as? any UNUserNotificationCenterDelegate
            // Request notification permission as soon as the app launches
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if granted {
                    print("Notification permissions granted.")
                } else if let error = error {
                    print("Notification permissions denied: \(error)")
                }
            }
        }
    
    var body: some Scene {
        WindowGroup {
            
            ProfileListView()
                .background(Color.cBlue)
                .background(ignoresSafeAreaEdges: .all)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
    
    func requestNotificationPermission() {
        UserNotifications.UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permissions granted.")
            } else if let error = error {
                print("Notification permissions not granted: \(error)")
            }
        }
    }
    
    class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
        func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            completionHandler([.banner, .list, .sound])  // Customize based on your needs
        }
    }



}
