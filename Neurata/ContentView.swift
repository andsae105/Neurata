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
            Tab("Tests", systemImage: "list.bullet") {
                NavigationStack {
                    ChooseScreen()
                }
            }
            Tab("Data", systemImage: "chart.bar") {
                ResultsDashboardView()
            }
            Tab("Results", systemImage: "list.clipboard") {
                TestLibraryView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(AppDataManager())
}
