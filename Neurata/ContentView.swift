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
                ResultsDashboardView()
            }
            Tab("Test Library", systemImage: "book") {
                TestLibraryView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(AppDataManager())
}




