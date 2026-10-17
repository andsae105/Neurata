//
//  DataScreen.swift
//  Neurata
//
//  Created by Ishan Karmakar on 10/17/26.
//

import SwiftUI

struct DashboardAndLibraryView: View {
    @Environment(AppDataManager.self) private var dataManager
    
    // UI Computations for Dashboard
    private var averageAccuracy: Double {
        guard !dataManager.testResults.isEmpty else { return 0.0 }
        let totalScore = dataManager.testResults.reduce(0) { $0 + $1.score }
        let totalQuestions = dataManager.testResults.reduce(0) { $0 + $1.totalQuestions }
        return (Double(totalScore) / Double(totalQuestions)) * 100
    }
    
    private var grandAverageReactionTime: TimeInterval {
        guard !dataManager.testResults.isEmpty else { return 0.0 }
        let sum = dataManager.testResults.reduce(0.0) { $0 + $1.averageResponseTime }
        return sum / Double(dataManager.testResults.count)
    }

    var body: some View {
        NavigationStack {
            List {
                // SECTION 1: COMPREHENSIVE DATA METRICS
                Section(header: Text("Analytics Dashboard")) {
                    if dataManager.testResults.isEmpty {
                        Text("No data profiles recorded yet. Complete a Stroop test to generate insights.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.vertical, 8)
                    } else {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("Total Runs Saved:")
                                    .bold()
                                Spacer()
                                Text("\(dataManager.testResults.count)")
                            }
                            
                            HStack {
                                Text("Global Avg Accuracy:")
                                    .bold()
                                Spacer()
                                Text(String(format: "%.1f%%", averageAccuracy))
                                    .foregroundColor(.blue)
                            }
                            
                            HStack {
                                Text("Global Response Speed:")
                                    .bold()
                                Spacer()
                                Text(String(format: "%.0f ms", grandAverageReactionTime * 1000))
                                    .foregroundColor(.purple)
                                    .font(.system(.body, design: .monospaced))
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
                
                // SECTION 2: TEST LIBRARY HISTORY
                Section(header: Text("Historical Test Library")) {
                    if dataManager.testResults.isEmpty {
                        Text("Library empty.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(dataManager.testResults) { result in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("\(result.formattedDate) — \(result.testName)")
                                        .font(.subheadline)
                                        .bold()
                                    Spacer()
                                    Text("Acc: \(Int((Double(result.score) / Double(result.totalQuestions)) * 100))%")
                                        .font(.caption)
                                        .bold()
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(6)
                                }
                                
                                Text(String(format: "Avg Speed: %.0f ms", result.averageResponseTime * 1000))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                // Integrated Inline Tagline Binding Setup
                                TextField("Add description (e.g., 'the day I felt sick')", text: Binding(
                                    get: { result.tagline },
                                    set: { newTagline in
                                        if let targetIndex = dataManager.testResults.firstIndex(where: { $0.id == result.id }) {
                                            dataManager.testResults[targetIndex].tagline = newTagline
                                        }
                                    }
                                ))
                                .font(.caption)
                                .textFieldStyle(.roundedBorder)
                            }
                            .padding(.vertical, 6)
                        }
                    }
                }
            }
            .navigationTitle("Cognitive Data Hub")
        }
    }
}


