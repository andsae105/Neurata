//
//  NewTestScreen.swift
//  Neurata
//
//  Created by Ishan Karmakar on 10/17/26.
//

import SwiftUI

struct DisclaimerScreen: View {
    var body: some View {
        NavigationStack {
            VStack (spacing:9) {
                Text("Disclaimer!")
                    .bold()
                    .fontWeight(.heavy)
                    .font(.system(size: 60))
                Text("Before you Begin:")
                    .bold()
                    .font(.system(size: 20))
                Text("This test's only purpose is to test cognitivity, which include your memory, attention, and reaction time.")
                    .multilineTextAlignment(.center)
                Text("")
                Text("This test does not indicate how inteligent you are or abilities that you're capable of, and strictly only tests how well you're able to perform specific tasks. ")
                    .multilineTextAlignment(.center)
                NavigationLink("I Understand - Begin Test"){
                    NewTestScreen()
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
    DisclaimerScreen()
}
