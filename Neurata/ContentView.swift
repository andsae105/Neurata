//
//  ContentView.swift
//  Neurata
//
//  Created by Andres Saenz on 10/16/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                HomeScreen()
            }
            Tab("Data", systemImage: "chart.bar") {
                DashboardAndLibraryView()
            }
            Tab("Test Library", systemImage: "book") {
                DashboardAndLibraryView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(AppDataManager()) // Fixes the crash for this preview
}




