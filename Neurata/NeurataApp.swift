//
//  NeurataApp.swift
//  Neurata
//
//  Created by Andres Saenz on 10/16/26.
//

import SwiftUI

@main
struct NeurataApp: App {
    @State private var dataManager = AppDataManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(dataManager)
        }
    }
}

