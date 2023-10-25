//
//  Headway_Test_TaskApp.swift
//  Headway Test Task
//
//  Created by Dmytro Kopanytsia on 25.10.2023.
//

import SwiftUI

@main
struct Headway_Test_TaskApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
