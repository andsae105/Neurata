//
//  ContentView.swift
//  Neurata
//
//  Created by Andres Saenz on 10/16/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack (spacing:10) {
                Text("Neureta")
                    .bold()
                    .fontWeight(.heavy)
                    .font(.system(size: 75))
                Button("New Test"){                   /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
                }
                    .safeAreaPadding(/*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                    .background(/*@START_MENU_TOKEN@*//*@PLACEHOLDER=View@*/Color.blue/*@END_MENU_TOKEN@*/)
            }
            .padding(20)
            .toolbar {
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button(action: {}) {
                        Image(systemName: "chart.bar")
                    }
                    Button(action: {}) {
                        Image(systemName: "book")
                    }
                }
            }
        }
    }
}


#Preview {
    ContentView()
}
