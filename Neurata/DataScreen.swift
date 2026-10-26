//
//  DataScreen.swift
//  Neurata
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

    private var allAttentionPoints: [AccuracyDataPoint] {
        var list: [AccuracyDataPoint] = []
        for result in dataManager.testResults {
            list.append(
                AccuracyDataPoint(
                    score: result.score,
                    totalQuestions: result.totalQuestions,
                    averageResponseTime: result.averageResponseTime,
                    formattedDate: result.formattedDate,
                    date: result.date
                )
            )
        }
        for assessment in dataManager.fullAssessmentResults {
            list.append(
                AccuracyDataPoint(
                    score: assessment.stroopScore,
                    totalQuestions: assessment.stroopTotal,
                    averageResponseTime: assessment.stroopAverageResponseTime,
                    formattedDate: assessment.formattedDate,
                    date: assessment.date
                )
            )
        }
        return list.sorted { $0.date > $1.date }
    }

    private var averageAccuracy: Double {
        let points = allAttentionPoints
        guard !points.isEmpty else { return 0 }
        let totalScore = points.reduce(0) { $0 + $1.score }
        let totalQuestions = points.reduce(0) { $0 + $1.totalQuestions }
        guard totalQuestions > 0 else { return 0 }
        return (Double(totalScore) / Double(totalQuestions)) * 100
    }

    private var overallAverageTime: TimeInterval {
        let points = allAttentionPoints
        guard !points.isEmpty else { return 0 }
        let sumTime = points.reduce(0) { $0 + $1.averageResponseTime }
        return sumTime / Double(points.count)
    }

    private var insights: [CategoryInsight] {
        InsightEngine.insights(
            stroopResults: dataManager.testResults,
            corsiResults: dataManager.corsiResults,
            reactionResults: dataManager.reactionResults,
            fullAssessments: dataManager.fullAssessmentResults
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    DashboardDataSection(
                        points: allAttentionPoints,
                        averageAccuracy: averageAccuracy,
                        overallAverageTime: overallAverageTime
                    )
                    InsightsSectionView(insights: insights)
                }
                .padding(.vertical)
            }
            .navigationTitle("Data Summary")
        }
    }
}

struct DashboardDataSection: View {
    let points: [AccuracyDataPoint]
    let averageAccuracy: Double
    let overallAverageTime: TimeInterval

    var body: some View {
        if points.isEmpty {
            ContentUnavailableView(
                "No data available",
                systemImage: "chart.bar",
                description: Text("Complete a test to see data summary here")
            )
            .padding(.top, 40)
        } else {
            VStack(spacing: 24) {
                HStack(spacing: 16) {
                    DashboardMetricCard(
                        title: "Lifetime Accuracy",
                        value: averageAccuracy.formatted(.number.precision(.fractionLength(1))) + "%",
                        subtitle: "Averaged",
                        icon: "checkmark.circle.fill",
                        color: .blue
                    )

                    DashboardMetricCard(
                        title: "Reaction Time",
                        value: (overallAverageTime * 1_000)
                            .formatted(.number.precision(.fractionLength(0))) + " ms",
                        subtitle: "Averaged",
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
                        ForEach(points.reversed()) { point in
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
        }
    }
}

struct InsightsSectionView: View {
    let insights: [CategoryInsight]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Insights")
                .font(.title2.bold())
                .padding(.horizontal)

            Text("Summaries based off test history per category")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            ForEach(insights) { insight in
                CategoryInsightCard(insight: insight)
                    .padding(.horizontal)
            }
        }
    }
}

struct CategoryInsightCard: View {
    let insight: CategoryInsight

    private var accentColor: Color {
        switch insight.category {
        case .attentionControl:
            .orange
        case .memory:
            .green
        case .processingSpeed:
            .purple
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Label(insight.category.rawValue, systemImage: insight.category.iconName)
                    .font(.headline)
                    .foregroundStyle(accentColor)

                Spacer()

                if let tier = insight.tier {
                    Text(tier.title)
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(accentColor, in: Capsule())
                }
            }

            Text(insight.summary)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            if insight.hasData {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(insight.diagnostics, id: \.self) { diagnostic in
                        Label(diagnostic, systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                Label("No completed tests in this category", systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
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
                .font(.title)
                .bold()
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
    mockManager.corsiResults = [
        CorsiResult(memorySpan: 6, correctTrials: 4, totalTrials: 6)
    ]
    mockManager.reactionResults = [
        ReactionTimeResult(averageReactionTime: 285, fastestReactionTime: 230)
    ]
    return ResultsDashboardView().environment(mockManager)
}
