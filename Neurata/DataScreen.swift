//
//  DataScreen.swift
//  Neurata
//
//  Created by Ishan Karmakar on 10/17/26.
//

import SwiftUI
import Charts

struct ResultsDashboardView: View {
    @Environment(AppDataManager.self) private var dataManager
    
    var averageAccuracy: Double {
        guard !dataManager.testResults.isEmpty else { return 0.0 }
        let totalScore = dataManager.testResults.reduce(0) { $0 + $1.score }
        let totalQuestions = dataManager.testResults.reduce(0) { $0 + $1.totalQuestions }
        return (Double(totalScore) / Double(totalQuestions)) * 100
    }
    
    var overallAverageTime: TimeInterval {
        guard !dataManager.testResults.isEmpty else { return 0.0 }
        let sumTime = dataManager.testResults.reduce(0.0) { $0 + $1.averageResponseTime }
        return sumTime / Double(dataManager.testResults.count)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if dataManager.testResults.isEmpty {
                    ContentUnavailableView(
                        "No Data Available",
                        systemImage: "chart.xyaxis.line",
                        description: Text("Complete tests to access analytics")
                    )
                    .padding(.top, 40)
                } else {
                    VStack(spacing: 24) {
                        HStack(spacing: 16) {
                            DashboardMetricCard(
                                title: "Lifetime Accuracy",
                                value: String(format: "%.1f%%", averageAccuracy),
                                subtitle: "\(dataManager.testResults.count) tests logged",
                                icon: "checkmark.circle.fill",
                                color: .green
                            )
                            
                            DashboardMetricCard(
                                title: "Avg Reaction Time",
                                value: String(format: "%.0f ms", overallAverageTime * 1000),
                                subtitle: "Lower is faster",
                                icon: "bolt.fill",
                                color: .purple
                            )
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Accuracy Trends Over Time")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            Chart {
                                ForEach(dataManager.testResults.reversed()) { result in
                                    let percentage = (Double(result.score) / Double(result.totalQuestions)) * 100
                                    
                                    LineMark(
                                        x: .value("Date", result.formattedDate),
                                        y: .value("Accuracy", percentage)
                                    )
                                    .interpolationMethod(.catmullRom)
                                    .foregroundStyle(Color.blue)
                                    .lineStyle(StrokeStyle(lineWidth: 3))
                                    
                                    PointMark(
                                        x: .value("Date", result.formattedDate),
                                        y: .value("Accuracy", percentage)
                                    )
                                    .foregroundStyle(.blue)
                                }
                            }
                            .frame(height: 220)
                            .chartYScale(domain: 0...100)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Analytics View")
        }
    }
}

struct DashboardMetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .bold()
                    .foregroundColor(.secondary)
            }
            Text(value)
                .font(.title).bold()
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

#Preview {
    let mockManager = AppDataManager()
    mockManager.testResults = [
        StroopResult(date: Date().addingTimeInterval(-172800), score: 12, totalQuestions: 20, averageResponseTime: 0.950),
        StroopResult(date: Date().addingTimeInterval(-86400), score: 16, totalQuestions: 20, averageResponseTime: 0.720),
        StroopResult(date: Date(), score: 19, totalQuestions: 20, averageResponseTime: 0.580)
    ]
    return ResultsDashboardView().environment(mockManager)
}
