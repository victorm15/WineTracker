//
//  coretestsApp.swift
//  coretests
//
//  Created by Victor Mauger on 08.07.2024.
//

import SwiftUI

@main
    struct coretestsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .statusBar(hidden: true)
        }
    }
}
