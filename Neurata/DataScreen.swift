//
//  DataScreen.swift
//  Neurata
//
//  Created by Ishan Karmakar on 10/17/26.
//

import SwiftUI
import Charts

struct AccuracyDataPoint: Identifiable {
    let id = UUID()
    let score: Int
    let totalQuestions: Int
    let averageResponseTime: TimeInterval
    let formattedDate: String
    let date: Date
    
    var percentage: Double {
        guard totalQuestions > 0 else { return 0 }
        return (Double(score) / Double(totalQuestions)) * 100
    }
}

struct ResultsDashboardView: View {
    @Environment(AppDataManager.self) private var dataManager
    
    var allAttentionPoints: [AccuracyDataPoint] {
        var list: [AccuracyDataPoint] = []
        for r in dataManager.testResults {
            list.append(AccuracyDataPoint(score: r.score, totalQuestions: r.totalQuestions, averageResponseTime: r.averageResponseTime, formattedDate: r.formattedDate, date: r.date))
        }
        for f in dataManager.fullAssessmentResults {
            list.append(AccuracyDataPoint(score: f.stroopScore, totalQuestions: f.stroopTotal, averageResponseTime: f.stroopAverageResponseTime, formattedDate: f.formattedDate, date: f.date))
        }
        return list.sorted(by: { $0.date > $1.date })
    }
    
    var averageAccuracy: Double {
        let points = allAttentionPoints
        guard !points.isEmpty else { return 0.0 }
        let totalScore = points.reduce(0) { $0 + $1.score }
        let totalQuestions = points.reduce(0) { $0 + $1.totalQuestions }
        return (Double(totalScore) / Double(totalQuestions)) * 100
    }
    
    var overallAverageTime: TimeInterval {
        let points = allAttentionPoints
        guard !points.isEmpty else { return 0.0 }
        let sumTime = points.reduce(0.0) { $0 + $1.averageResponseTime }
        return sumTime / Double(points.count)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if allAttentionPoints.isEmpty {
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
                                value: String(format: "%.1f%%", averageAccuracy), subtitle: "Averaged",
                                icon: "checkmark.circle.fill",
                                color: .blue
                            )
                            
                            DashboardMetricCard(
                                title: "Reaction Time",
                                value: String(format: "%.0f ms", overallAverageTime * 1000), subtitle: "Averaged",
                                icon: "bolt.fill",
                                color: .blue
                            )
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Accuracy Trends")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            Chart {
                                ForEach(allAttentionPoints.reversed()) { point in
                                    LineMark(
                                        x: .value("Date", point.formattedDate),
                                        y: .value("Accuracy", point.percentage)
                                    )
                                    .interpolationMethod(.catmullRom)
                                    .foregroundStyle(Color.blue)
                                    .lineStyle(StrokeStyle(lineWidth: 3))
                                    
                                    PointMark(
                                        x: .value("Date", point.formattedDate),
                                        y: .value("Accuracy", point.percentage)
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
            .navigationTitle("Data Summary")
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
