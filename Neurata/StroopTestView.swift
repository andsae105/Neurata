//
//  StroopTestView.swift
//  Neurata
//
//  Created by Ishan Karmakar on 10/17/26.
//
import SwiftUI

struct StroopTestView: View {
    @Environment(AppDataManager.self) private var dataManager
    
    // Core Gameplay State
    @State private var textWord: StroopColor = .red
    @State private var fontColor: StroopColor = .blue
    @State private var totalAttempts: Int = 0
    @State private var score: Int = 0
    @State private var isGameOver: Bool = false
    
    // Time Analytics Tracking
    @State private var questionStartTime: Date = Date()
    @State private var totalReactionTime: TimeInterval = 0.0
    
    let maxQuestions = 20
    
    // Strict 2x2 Layout parameters
    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        VStack(spacing: 30) {
            if isGameOver {
                // Completed State Screen
                VStack(spacing: 24) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                    
                    Text("Test Complete!")
                        .font(.largeTitle)
                        .bold()
                    
                    Text("Your performance profile has been cataloged in your Test Library screen.")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                    
                    Button(action: resetGame) {
                        Text("Take Another Test")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                }
                .transition(.scale)
            } else {
                // Ongoing Gameplay Screen
                VStack {
                    Spacer()
                    
                    VStack(spacing: 20) {
                        Text(textWord.rawValue)
                            .font(.system(size: 64, weight: .black, design: .rounded))
                            .foregroundColor(fontColor.displayColor)
                        
                        VStack(spacing: 8) {
                            Text("Tap the color of the FONT, ignore the word!")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                            
                            Text("Question \(totalAttempts + 1) of \(maxQuestions)")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Large 2x2 Grid of Rounded Squares
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(StroopColor.allCases, id: \.self) { colorOption in
                            Button(action: {
                                self.checkAnswer(selectedColor: colorOption)
                            }) {
                                Text(colorOption.rawValue)
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, minHeight: 140)
                                    .background(colorOption.displayColor)
                                    .cornerRadius(24)
                                    .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                }
            }
        }
        .padding()
        .animation(.easeInOut, value: isGameOver)
        .onAppear {
            nextTurn()
        }
    }
    
    func checkAnswer(selectedColor: StroopColor) {
        let elapsed = Date().timeIntervalSince(questionStartTime)
        totalReactionTime += elapsed
        
        if selectedColor == fontColor {
            score += 1
        }
        
        totalAttempts += 1
        
        if totalAttempts >= maxQuestions {
            let avgTime = totalReactionTime / Double(maxQuestions)
            // Save directly into the environment
            dataManager.addResult(score: score, total: maxQuestions, avgTime: avgTime)
            isGameOver = true
        } else {
            nextTurn()
        }
    }
    
    func nextTurn() {
        textWord = StroopColor.allCases.randomElement() ?? .red
        fontColor = StroopColor.allCases.randomElement() ?? .blue
        questionStartTime = Date()
    }
    
    func resetGame() {
        score = 0
        totalAttempts = 0
        totalReactionTime = 0.0
        isGameOver = false
        nextTurn()
    }
}
// ... your existing StroopTestView layout code ...

#Preview {
    StroopTestView()
        .environment(AppDataManager()) // Fixes the crash for this preview
}

