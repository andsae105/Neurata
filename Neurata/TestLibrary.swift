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
                if dataManager.testResults.isEmpty {
                    ContentUnavailableView(
                        "No Tests Taken Yet",
                        systemImage: "list.bullet.clipboard",
                        description: Text("Complete a Stroop Test to see your history logged here.")
                    )
                } else {
                    List {
                        ForEach(filteredResults) { result in
                            VStack(alignment: .leading, spacing: 10) {
                                // Row Header
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
                                        .foregroundColor(accuracyColor(for: result.score))
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
    
    private func accuracyColor(for score: Int) -> Color {
        let percentage = Double(score) / 20.0
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
