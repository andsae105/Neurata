//
//  TestLibrary.swift
//  Neurata
//
//  Created by Andres Saenz on 10/17/26.
//

import SwiftUI

struct TestLibraryView: View {
    @Environment(AppDataManager.self) private var dataManager
    
    @State private var searchText = ""
    
    var filteredFullAssessmentResults: [FullAssessmentResult] {
        if searchText.isEmpty {
            return dataManager.fullAssessmentResults
        } else {
            return dataManager.fullAssessmentResults.filter { result in
                result.tagline.localizedCaseInsensitiveContains(searchText) ||
                result.testName.localizedCaseInsensitiveContains(searchText) ||
                result.formattedDate.localizedCaseInsensitiveContains(searchText) ||
                "Attention".localizedCaseInsensitiveContains(searchText) ||
                "Memory".localizedCaseInsensitiveContains(searchText) ||
                "Processing Speed".localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var filteredReactionResults: [ReactionTimeResult] {
        if searchText.isEmpty {
            return dataManager.reactionResults
        } else {
            return dataManager.reactionResults.filter { result in
                result.tagline.localizedCaseInsensitiveContains(searchText) ||
                result.testName.localizedCaseInsensitiveContains(searchText) ||
                result.formattedDate.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var filteredCorsiResults: [CorsiResult] {
        if searchText.isEmpty {
            return dataManager.corsiResults
        } else {
            return dataManager.corsiResults.filter { result in
                result.tagline.localizedCaseInsensitiveContains(searchText) ||
                result.testName.localizedCaseInsensitiveContains(searchText) ||
                result.formattedDate.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var filteredResults: [StroopResult] {
        if searchText.isEmpty {
            return dataManager.testResults
        } else {
            return dataManager.testResults.filter { result in
                result.tagline.localizedCaseInsensitiveContains(searchText) ||
                result.testName.localizedCaseInsensitiveContains(searchText) ||
                result.formattedDate.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if dataManager.testResults.isEmpty &&
                   dataManager.corsiResults.isEmpty &&
                   dataManager.reactionResults.isEmpty &&
                   dataManager.fullAssessmentResults.isEmpty {
                    ContentUnavailableView(
                        "No tests saved yet",
                        systemImage: "list.clipboard",
                        description: Text("Complete a test to see results logged here")
                    )
                } else {
                    List {
                        // Full Assessment Results
                        ForEach(filteredFullAssessmentResults) { result in
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("\(result.formattedDate) \(result.testName)")
                                            .font(.headline)
                                        Text("Attention: \(Int((Double(result.stroopScore) / Double(result.stroopTotal)) * 100))% • Memory: \(result.memorySpan) Blocks • Speed: \(Int(result.reactionAverageTime)) ms")
                                            .font(.subheadline)
                                            .foregroundColor(.blue)
                                            .monospacedDigit()
                                    }
                                    Spacer()

                                    Text("Full")
                                        .font(.caption.bold())
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.red, in: Capsule())
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Personal Note:")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                        .textCase(.uppercase)

                                    TextField("e.g., 'the day I felt sick' or 'after coffee'", text: Binding(
                                        get: { result.tagline },
                                        set: { newValue in
                                            if let index = dataManager.fullAssessmentResults.firstIndex(where: { $0.id == result.id }) {
                                                dataManager.fullAssessmentResults[index].tagline = newValue
                                            }
                                        }
                                    ))
                                    .font(.subheadline)
                                    .textFieldStyle(.roundedBorder)
                                }
                            }
                            .padding(.vertical, 6)
                        }

                        // Processing Speed (Reaction Time) Results
                        ForEach(filteredReactionResults) { result in
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("\(result.formattedDate) \(result.testName)")
                                            .font(.headline)
                                        Text("Fastest: \(Int(result.fastestReactionTime)) ms")
                                            .font(.subheadline)
                                            .foregroundColor(.blue)
                                            .monospacedDigit()
                                    }
                                    Spacer()

                                    Text("\(Int(result.averageReactionTime)) ms")
                                        .font(.title3)
                                        .bold()
                                        .foregroundColor(.purple)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Personal Note:")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                        .textCase(.uppercase)

                                    TextField("e.g., 'the day I felt sick' or 'after coffee'", text: Binding(
                                        get: { result.tagline },
                                        set: { newValue in
                                            if let index = dataManager.reactionResults.firstIndex(where: { $0.id == result.id }) {
                                                dataManager.reactionResults[index].tagline = newValue
                                            }
                                        }
                                    ))
                                    .font(.subheadline)
                                    .textFieldStyle(.roundedBorder)
                                }
                            }
                            .padding(.vertical, 6)
                        }

                        // Memory (Corsi) Results
                        ForEach(filteredCorsiResults) { result in
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("\(result.formattedDate) \(result.testName)")
                                            .font(.headline)
                                        Text("Correct Sequences: \(result.correctTrials)/\(result.totalTrials)")
                                            .font(.subheadline)
                                            .foregroundColor(.blue)
                                            .monospacedDigit()
                                    }
                                    Spacer()

                                    Text("\(result.memorySpan) Blocks")
                                        .font(.title3)
                                        .bold()
                                        .foregroundColor(.green)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Personal Note:")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                        .textCase(.uppercase)

                                    TextField("e.g., 'the day I felt sick' or 'after coffee'", text: Binding(
                                        get: { result.tagline },
                                        set: { newValue in
                                            if let index = dataManager.corsiResults.firstIndex(where: { $0.id == result.id }) {
                                                dataManager.corsiResults[index].tagline = newValue
                                            }
                                        }
                                    ))
                                    .font(.subheadline)
                                    .textFieldStyle(.roundedBorder)
                                }
                            }
                            .padding(.vertical, 6)
                        }

                        // Attention Control (Stroop) Results
                        ForEach(filteredResults) { result in
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("\(result.formattedDate) \(result.testName)")
                                            .font(.headline)
                                        Text("Avg Response: \(Int(result.averageResponseTime * 1000)) ms")
                                            .font(.subheadline)
                                            .foregroundColor(.blue)
                                            .monospacedDigit()
                                    }
                                    Spacer()
                                    
                                    Text("\(Int((Double(result.score) / Double(result.totalQuestions)) * 100))%")
                                        .font(.title3)
                                        .bold()
                                        .foregroundColor(accuracyColor(for: result.score, total: result.totalQuestions))
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Personal Note:")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                        .textCase(.uppercase)
                                    
                                    TextField("e.g., 'the day I felt sick' or 'after coffee'", text: Binding(
                                        get: { result.tagline },
                                        set: { newValue in
                                            if let index = dataManager.testResults.firstIndex(where: { $0.id == result.id }) {
                                                dataManager.testResults[index].tagline = newValue
                                            }
                                        }
                                    ))
                                    .font(.subheadline)
                                    .textFieldStyle(.roundedBorder)
                                }
                            }
                            .padding(.vertical, 6)
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search by date or notes")
                }
            }
            .navigationTitle("Test Library")
        }
    }
    
    private func accuracyColor(for score: Int, total: Int) -> Color {
        let percentage = Double(score) / Double(total)
        if percentage >= 0.85 { return .green }
        if percentage >= 0.65 { return .orange }
        return .red
    }
}

#Preview {
    let mockManager = AppDataManager()
    mockManager.fullAssessmentResults = [
        FullAssessmentResult(
            date: Date(),
            stroopScore: 10,
            stroopTotal: 10,
            stroopAverageResponseTime: 0.52,
            memorySpan: 6,
            memoryCorrectTrials: 5,
            memoryTotalTrials: 6,
            reactionAverageTime: 235,
            reactionFastestTime: 210,
            tagline: "Great morning session"
        )
    ]
    mockManager.reactionResults = [
        ReactionTimeResult(date: Date(), averageReactionTime: 242, fastestReactionTime: 215, totalTrials: 3, tagline: "Quick reflexes today")
    ]
    mockManager.testResults = [
        StroopResult(date: Date(), score: 19, totalQuestions: 20, averageResponseTime: 0.540, tagline: "Feeling fully alert"),
        StroopResult(date: Date().addingTimeInterval(-86400), score: 14, totalQuestions: 20, averageResponseTime: 0.820, tagline: "The day I felt sick")
    ]
    mockManager.corsiResults = [
        CorsiResult(date: Date(), memorySpan: 6, correctTrials: 5, totalTrials: 7, tagline: "Feeling focused"),
        CorsiResult(date: Date().addingTimeInterval(-86400), memorySpan: 4, correctTrials: 3, totalTrials: 6, tagline: "Tired after study session")
    ]
    return TestLibraryView().environment(mockManager)
}
