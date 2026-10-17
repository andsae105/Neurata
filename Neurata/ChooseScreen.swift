//
//  NewTestScreen.swift
//  Neurata
//
//  Created by Ishan Karmakar on 10/17/26.
//

import SwiftUI


struct ChooseScreen: View {
    var body: some View {
        ScrollView{
            VStack(spacing: 15) {
                TestBubble(
                    title: "Full Assesment",
                    subtitle: "",
                    color: .white,
                    color2: .red
                )
                .overlay(alignment: .bottomTrailing) {
                    NavigationLink("Start Test →") {
                        AttentionControlTestScreen()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.trailing, 40)
                    .padding(.bottom, 20)
                }
                TestBubble(
                    title: "Attention Control",
                    subtitle: "Test how well you can focus and ignore any distractions using the Stroop & Framer Test. ",
                    color: .white,
                    color2: .orange
                )
                .overlay(alignment: .bottomTrailing) {
                    NavigationLink("Start Test →") {
                        AttentionControlTestScreen()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.trailing, 40)
                    .padding(.bottom, 20)
                }
                
                TestBubble(
                    title: "Memory",
                    subtitle: "",
                    color: .white,
                    color2: .green
                )
                .overlay(alignment: .bottomTrailing) {
                    NavigationLink("Start Test →") {
                        MemoryTestScreen()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.trailing, 40)
                    .padding(.bottom, 20)
                }
                
                TestBubble(
                    title: "Processing Speed",
                    subtitle: "Pattern Comparison and Reaction Time",
                    color: .white,
                    color2: .purple
                )
                .overlay(alignment: .bottomTrailing) {
                    NavigationLink("Start Test →") {
                        Text("Attention Test")
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.trailing, 40)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Test Selection")
            .navigationBarTitleDisplayMode(.large)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}
struct TestBubble: View {
    let title: String
    let subtitle: String
    let color: Color
    let color2: Color
    

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title2)
                .bold()
                .foregroundStyle(color2)

            Text(subtitle)
                .font(.subheadline)

        }
        .frame(maxWidth: .infinity, minHeight: 160, alignment: .topLeading)
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(color.opacity(0.18))
                }
        }
        .padding(.horizontal, 20)
    }
}


#Preview {
    NavigationStack {
        ChooseScreen()
    }
}
