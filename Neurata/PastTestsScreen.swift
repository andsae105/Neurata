//
//  PastTests.swift
//  Neurata
//
//  Created by Ishan Karmakar on 10/17/26.
//

import SwiftUI

struct PastTestsScreen: View {
    var body: some View {
        NavigationStack {
            VStack (spacing:10){
                Text("Test Library")
                    .bold()
                    .fontWeight(.heavy)
                    .font(.system(size: 50))
            }
            .padding(20)
            }
    }
}

#Preview {
    PastTestsScreen()
}

