//
//  HomeScreen.swift
//  Neurata
//
//  Created by Ishan Karmakar on 10/17/26.
//

import SwiftUI

struct HomeScreen: View {
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
                    .background(.blue, in: RoundedRectangle(cornerRadius: 12))
                    .backgroundStyle(.orange)
                    .foregroundStyle(.white)
            }
            .padding(20)
            }
    }
}

#Preview {
    HomeScreen()
}
