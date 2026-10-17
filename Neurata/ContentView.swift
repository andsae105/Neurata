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
                DataScreen()
            }
            Tab("Test Library", systemImage: "book") {
                PastTestsScreen()
            }
        }
    }
}


#Preview {
    ContentView()
}



