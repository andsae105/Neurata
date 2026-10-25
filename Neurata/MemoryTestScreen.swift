
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
    @State private var tappedIndex: Int? = nil
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
        VStack(spacing: 30) {
            if isGameOver {
                VStack(spacing: 24) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 75))
                        .foregroundColor(.green)
                    
                    Text("Test Complete")
                        .font(.largeTitle)
                        .bold()
                    
                    Text("Your results have been saved in the Test Library")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                    
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
                        let isTapped = tappedIndex == index
                        let isHighlighted = highlightedIndex == index
                        let isActive = isTapped || isHighlighted
                        let outlineColor: Color = isHighlighted ? .yellow : (isTapped ? .white : .clear)
                        let shadowColor: Color = isHighlighted ? .yellow.opacity(0.8) : (isTapped ? .cyan.opacity(0.8) : .clear)
                        RoundedRectangle(cornerRadius: 10)
                            .fill(blockColor(index))
                            .frame(width: 65, height: 65)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(outlineColor, lineWidth: 3)
                            )
                            .shadow(
                                color: shadowColor,
                                radius: 8
                            )
                            .scaleEffect(isActive ? 0.88 : 1.0)
                            .offset(
                                x: positions[index].x,
                                y: positions[index].y
                            )
                            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isActive)
                            .onTapGesture {
                                handleSquareTap(index)
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
            return "Watch the blocks light up"
        } else {
            return "Tap the blocks in the same order"
        }
    }

    func handleSquareTap(_ index: Int) {
        guard !isPlayingSequence, !isGameOver else { return }

        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
            tappedIndex = index
        }

        Task {
            try? await Task.sleep(for: .milliseconds(180))
            if tappedIndex == index {
                withAnimation(.easeOut(duration: 0.15)) {
                    tappedIndex = nil
                }
            }
        }

        playerSequence.append(index)

        if playerSequence.count == sequence.count {
            checkAnswer()
        }
    }

    func blockColor(_ index: Int) -> Color {
        if index == highlightedIndex {
            return .yellow
        } else if index == tappedIndex {
            return .cyan
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

                withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                    highlightedIndex = block
                }
                try await Task.sleep(for: .seconds(1))

                withAnimation(.easeOut(duration: 0.2)) {
                    highlightedIndex = -1
                }
                try await Task.sleep(for: .milliseconds(400))
            }
        } catch {
            withAnimation(.easeOut(duration: 0.2)) {
                highlightedIndex = -1
            }
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
        tappedIndex = nil

        dataManager.addCorsiResult(
            span: bestSpan,
            correct: correctTrials,
            total: totalTrials
        )
    }

    func resetGame() {
        highlightedIndex = -1
        tappedIndex = nil
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

