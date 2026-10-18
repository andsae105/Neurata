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
                if dataManager.testResults.isEmpty && dataManager.corsiResults.isEmpty { 
                    ContentUnavailableView(
                        "No Tests Taken Yet",
                        systemImage: "list.bullet.clipboard",
                        description: Text("Complete a Stroop Test to see your history logged here.")
                    )
                } else {
                    List {
                        ForEach(dataManager.corsiResults) { result in
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Corsi Memory Test")
                                    .font(.headline)

                                Text(result.formattedDate)
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                HStack {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Maximum Memory Span")
                                            .font(.subheadline)

                                        Text("Correct Sequences: \(result.correctTrials)/\(result.totalTrials)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()

                                    Text("\(result.memorySpan) Blocks")
                                        .font(.title3)
                                        .bold()
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.vertical, 8)
                        }

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
    mockManager.testResults = [
        StroopResult(date: Date(), score: 19, totalQuestions: 20, averageResponseTime: 0.540, tagline: "Feeling fully alert"),
        StroopResult(date: Date().addingTimeInterval(-86400), score: 14, totalQuestions: 20, averageResponseTime: 0.820, tagline: "The day I felt sick")
    ]
    return TestLibraryView().environment(mockManager)
}
