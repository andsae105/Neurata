//
//  ReactionTimeTestView.swift
//  Neurata
//
//  Created by Ishan Karmakar on 10/18/26.
//

import SwiftUI

struct ReactionTimeTestView: View {
    @State private var phase = "start"
    @State private var message = "READY"
    @State private var boxColor = Color.blue
    @State private var startTime = Date()
    @State private var times: [Double] = []
    @State private var roundID = 0

    var body: some View {
        VStack(spacing: 25) {
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

            if phase == "done" {
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
        .padding()
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
                message = "Avg: \(Int(average)) ms"
                phase = "done"
            } else {
                message = "\(Int(time)) ms"
                phase = "result"
            }

            boxColor = .blue
        }
    }
}

#Preview {
    ReactionTimeTestView()
}

