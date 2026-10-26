//
//  ReactionTimeTestView.swift
//  Neurata
//
//  Created by Ishan Karmakar on 10/18/26.
//

import SwiftUI

struct ReactionTimeTestView: View {
    @Environment(AppDataManager.self) private var dataManager
    
    var isFullAssessment: Bool = false
    var onComplete: ((_ avgTime: Double, _ fastestTime: Double) -> Void)? = nil

    @State private var phase = "start"
    @State private var message = "READY"
    @State private var boxColor = Color.blue
    @State private var startTime = Date()
    @State private var times: [Double] = []
    @State private var roundID = 0
    @State private var isGameOver = false

    var body: some View {
        VStack(spacing: 25) {
            if isGameOver {
                VStack(spacing: 24) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 75))
                        .foregroundColor(.blue)

                    Text("Test Complete")
                        .font(.largeTitle)
                        .bold()

                    Text("Your results have been saved in the Test Library")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)

                    if let fastest = times.sorted().first {
                        let average = times.reduce(0, +) / Double(times.count)
                        VStack(spacing: 6) {
                            Text("Fastest: \(Int(fastest)) ms")
                                .font(.headline)
                                .foregroundColor(.purple)
                            Text("Average: \(Int(average)) ms")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }

                    Button(action: resetGame) {
                        Text("Take Again")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal, 70)
                    .padding(.top, 20)
                }
                .transition(.scale)
            } else {
                Text("REACTION TIME")
                    .font(.system(size: 40, weight: .black, design: .rounded))

                Text("Wait for green, then tap as fast as possible!")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text("Trial \(min(times.count + 1, 3)) of 3")
                    .font(.headline)

                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(boxColor)

                    Text(message)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(height: 300)
                .onTapGesture {
                    tapped()
                }

                if phase == "done" && !isFullAssessment {
                    Text("Fastest: \(Int(times.sorted()[0])) ms")
                        .font(.headline)
                }

                if phase != "wait" && phase != "tap" {
                    Button("Start / Next") {
                        if phase == "done" {
                            times.removeAll()
                        }
                        startRound()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding()
        .animation(.easeInOut, value: isGameOver)
    }

    func startRound() {
        phase = "wait"
        message = "WAIT"
        boxColor = .red
        roundID += 1

        let currentRound = roundID

        DispatchQueue.main.asyncAfter(
            deadline: .now() + Double.random(in: 2...5)
        ) {
            if phase == "wait" && currentRound == roundID {
                startTime = Date()
                phase = "tap"
                message = "TAP!"
                boxColor = .green
            }
        }
    }

    func tapped() {
        if phase == "wait" {
            roundID += 1
            phase = "early"
            message = "TOO SOON!"
            boxColor = .orange

        } else if phase == "tap" {
            let time = Date().timeIntervalSince(startTime) * 1000
            times.append(time)

            if times.count == 3 {
                let average = times.reduce(0, +) / 3
                let fastest = times.sorted().first ?? average
                message = "Avg: \(Int(average)) ms"
                phase = "done"

                if isFullAssessment {
                    onComplete?(average, fastest)
                } else {
                    dataManager.addReactionResult(avgTime: average, fastestTime: fastest, trials: 3)
                    isGameOver = true
                }
            } else {
                message = "\(Int(time)) ms"
                phase = "result"
            }

            boxColor = .blue
        }
    }

    func resetGame() {
        times.removeAll()
        phase = "start"
        message = "READY"
        boxColor = .blue
        roundID = 0
        isGameOver = false
    }
}

#Preview {
    ReactionTimeTestView()
        .environment(AppDataManager())
}
