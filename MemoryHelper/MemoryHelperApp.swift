//
//  MemoryHelperApp.swift
//  MemoryHelper
//
//  Created by Luca Mac on 30/01/25.
//

import SwiftUI

@main
struct MemoryHelperApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
