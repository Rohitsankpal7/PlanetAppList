//
//  PlanetAppListApp.swift
//  PlanetAppList
//
//  Created by Rohit Sankpal on 16/01/25.
//

import SwiftUI
import SwiftData

@main
struct PlanetAppListApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PlanetModel.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
