//
//  HestiaHubApp.swift
//  HestiaHub
//
//  Created by 朱麟凱 on 4/28/24.
//

import SwiftUI

@main
struct HestiaHubApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
