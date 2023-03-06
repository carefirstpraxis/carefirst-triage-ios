//
//  carefirst_triage_iosApp.swift
//  carefirst-triage-ios
//
//  Created by Nick Sophinos on 3/5/23.
//

import SwiftUI

@main
struct carefirst_triage_iosApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
