
import SwiftUI

@MainActor
struct MemoryTestScreen: View {
    @Environment(AppDataManager.self) private var dataManager

    let positions: [CGPoint] = [
        CGPoint(x: -90, y: -70),
        CGPoint(x: 90, y: -40),
        CGPoint(x: 0, y: 100),
        CGPoint(x: -10, y: -145),
        CGPoint(x: 105, y: -145),
        CGPoint(x: 4, y: -38),
        CGPoint(x: -110, y: 25),
        CGPoint(x: 105, y: 70),
        CGPoint(x: -105, y: 125)
    ]

    @State private var highlightedIndex = -1
    @State private var sequence: [Int] = []
    @State private var playerSequence: [Int] = []
    @State private var sequenceLength = 2
    @State private var failedAttempts = 0
    @State private var isPlayingSequence = false
    @State private var isGameOver = false

    @State private var bestSpan = 0
    @State private var correctTrials = 0
    @State private var totalTrials = 0

    var body: some View {
        VStack(spacing: 20) {
            if isGameOver {
                Spacer()

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 75))
                    .foregroundColor(.green)

                Text("Test Complete!")
                    .font(.largeTitle)
                    .bold()

                Text("Your Memory Span")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Text("\(bestSpan) Blocks")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundColor(.blue)

                Text("Correct sequences: \(correctTrials) of \(totalTrials)")
                    .font(.subheadline)

                Text("Your result has been saved to the Test Library.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Button("Take Another Test") {
                    resetGame()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 20)

                Spacer()
            } else {
                Spacer(minLength: 10)

                Text("MEMORY")
                    .font(.system(size: 54, weight: .black, design: .rounded))

                Text(instructionText())
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Text("Sequence Length: \(sequenceLength)")
                    .font(.headline)

                ZStack {
                    ForEach(positions.indices, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 10)
                            .fill(blockColor(index))
                            .frame(width: 65, height: 65)
                            .offset(
                                x: positions[index].x,
                                y: positions[index].y
                            )
                            .onTapGesture {
                                if isPlayingSequence == false &&
                                    isGameOver == false {
                                    playerSequence.append(index)

                                    if playerSequence.count == sequence.count {
                                        checkAnswer()
                                    }
                                }
                            }
                    }
                }
                .frame(height: 360)

                Text("Taps: \(playerSequence.count) / \(sequenceLength)")
                    .foregroundColor(.secondary)

                Spacer(minLength: 10)
            }
        }
        .padding()
        .onAppear {
            if sequence.isEmpty && isGameOver == false {
                startRound()
            }
        }
    }

    func instructionText() -> String {
        if isPlayingSequence {
            return "Watch the blocks light up."
        } else {
            return "Tap the blocks in the same order."
        }
    }

    func blockColor(_ index: Int) -> Color {
        if index == highlightedIndex {
            return .yellow
        } else {
            return .blue
        }
    }

    func generateSequence() {
        sequence.removeAll()

        while sequence.count < sequenceLength {
            let randomNumber = Int.random(in: 0...8)

            if !sequence.contains(randomNumber) {
                sequence.append(randomNumber)
            }
        }
    }

    func startRound() {
        playerSequence.removeAll()
        generateSequence()
        isPlayingSequence = true

        Task {
            await playSequence()
        }
    }

    func playSequence() async {
        do {
            try await Task.sleep(for: .milliseconds(600))

            for block in sequence {
                try Task.checkCancellation()

                highlightedIndex = block
                try await Task.sleep(for: .seconds(1))

                highlightedIndex = -1
                try await Task.sleep(for: .milliseconds(400))
            }
        } catch {
            highlightedIndex = -1
            isPlayingSequence = false
            return
        }

        isPlayingSequence = false
    }

    func checkAnswer() {
        totalTrials += 1

        let correct = playerSequence == sequence
        playerSequence.removeAll()

        if correct {
            correctTrials += 1
            bestSpan = max(bestSpan, sequenceLength)
            failedAttempts = 0

            if sequenceLength < 9 {
                sequenceLength += 1
                startRound()
            } else {
                finishTest()
            }
        } else {
            failedAttempts += 1

            if failedAttempts < 2 {
                startRound()
            } else {
                finishTest()
            }
        }
    }

    func finishTest() {
        if isGameOver {
            return
        }

        isGameOver = true
        isPlayingSequence = false
        highlightedIndex = -1

        dataManager.addCorsiResult(
            span: bestSpan,
            correct: correctTrials,
            total: totalTrials
        )
    }

    func resetGame() {
        highlightedIndex = -1
        sequenceLength = 2
        failedAttempts = 0
        bestSpan = 0
        correctTrials = 0
        totalTrials = 0
        isGameOver = false
        startRound()
    }
}

#Preview {
    MemoryTestScreen()
        .environment(AppDataManager())
}
