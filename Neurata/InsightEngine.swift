import Foundation

enum CognitiveCategory: String, CaseIterable, Identifiable {
    case attentionControl = "Attention Control"
    case memory = "Memory"
    case processingSpeed = "Processing Speed"

    var id: Self { self }

    var iconName: String {
        switch self {
        case .attentionControl:
            "scope"
        case .memory:
            "brain.head.profile"
        case .processingSpeed:
            "bolt.fill"
        }
    }
}

enum PerformanceTier: String, Comparable {
    case optimal
    case average
    case developing

    var title: String {
        switch self {
        case .optimal:
            "Optimal"
        case .average:
            "Average"
        case .developing:
            "Developing"
        }
    }

    var score: Int {
        switch self {
        case .optimal:
            2
        case .average:
            1
        case .developing:
            0
        }
    }

    static func < (lhs: PerformanceTier, rhs: PerformanceTier) -> Bool {
        lhs.score < rhs.score
    }
}

struct CategoryInsight: Identifiable {
    let category: CognitiveCategory
    let tier: PerformanceTier?
    let summary: String
    let diagnostics: [String]
    let completedTests: Int

    var id: CognitiveCategory { category }

    var hasData: Bool { tier != nil }
}

struct InsightEngine {
    private struct CategorySample {
        let category: CognitiveCategory
        let tier: PerformanceTier
        let primaryMetric: Double
        let secondaryMetric: Double?
    }

    static func insights(
        stroopResults: [StroopResult],
        corsiResults: [CorsiResult],
        reactionResults: [ReactionTimeResult],
        fullAssessments: [FullAssessmentResult]
    ) -> [CategoryInsight] {
        let samples = normalizedSamples(
            stroopResults: stroopResults,
            corsiResults: corsiResults,
            reactionResults: reactionResults,
            fullAssessments: fullAssessments
        )

        return CognitiveCategory.allCases.map { category in
            insight(for: category, samples: samples.filter { $0.category == category })
        }
    }

    private static func normalizedSamples(
        stroopResults: [StroopResult],
        corsiResults: [CorsiResult],
        reactionResults: [ReactionTimeResult],
        fullAssessments: [FullAssessmentResult]
    ) -> [CategorySample] {
        let stroop = stroopResults.compactMap {
            attentionSample(
                accuracy: percentage(score: $0.score, total: $0.totalQuestions),
                reactionMilliseconds: $0.averageResponseTime * 1_000
            )
        }
        let corsi = corsiResults.map {
            memorySample(blocksCorrect: $0.memorySpan)
        }
        let reaction = reactionResults.compactMap {
            processingSpeedSample(
                averageMilliseconds: $0.averageReactionTime,
                fastestMilliseconds: $0.fastestReactionTime
            )
        }
        let fullAssessmentSamples = fullAssessments.flatMap { assessment -> [CategorySample] in
            var samples: [CategorySample] = []

            if let attention = attentionSample(
                accuracy: percentage(score: assessment.stroopScore, total: assessment.stroopTotal),
                reactionMilliseconds: assessment.stroopAverageResponseTime * 1_000
            ) {
                samples.append(attention)
            }

            samples.append(memorySample(blocksCorrect: assessment.memorySpan))

            if let speed = processingSpeedSample(
                averageMilliseconds: assessment.reactionAverageTime,
                fastestMilliseconds: assessment.reactionFastestTime
            ) {
                samples.append(speed)
            }

            return samples
        }

        return stroop + corsi + reaction + fullAssessmentSamples
    }

    private static func attentionSample(
        accuracy: Double?,
        reactionMilliseconds: Double
    ) -> CategorySample? {
        guard let accuracy, reactionMilliseconds > 0 else { return nil }

        let tier: PerformanceTier
        if accuracy >= 90, reactionMilliseconds <= 700 {
            tier = .optimal
        } else if accuracy >= 75, reactionMilliseconds <= 1_000 {
            tier = .average
        } else {
            tier = .developing
        }

        return CategorySample(
            category: .attentionControl,
            tier: tier,
            primaryMetric: accuracy,
            secondaryMetric: reactionMilliseconds
        )
    }

    private static func memorySample(blocksCorrect: Int) -> CategorySample {
        let tier: PerformanceTier
        switch blocksCorrect {
        case 7...:
            tier = .optimal
        case 5...:
            tier = .average
        default:
            tier = .developing
        }

        return CategorySample(
            category: .memory,
            tier: tier,
            primaryMetric: Double(blocksCorrect),
            secondaryMetric: nil
        )
    }

    private static func processingSpeedSample(
        averageMilliseconds: Double,
        fastestMilliseconds: Double
    ) -> CategorySample? {
        guard averageMilliseconds > 0, fastestMilliseconds > 0 else { return nil }

        let tier: PerformanceTier
        if averageMilliseconds <= 300, fastestMilliseconds <= 250 {
            tier = .optimal
        } else if averageMilliseconds <= 500, fastestMilliseconds <= 400 {
            tier = .average
        } else {
            tier = .developing
        }

        return CategorySample(
            category: .processingSpeed,
            tier: tier,
            primaryMetric: averageMilliseconds,
            secondaryMetric: fastestMilliseconds
        )
    }

    private static func insight(
        for category: CognitiveCategory,
        samples: [CategorySample]
    ) -> CategoryInsight {
        guard !samples.isEmpty else {
            return CategoryInsight(
                category: category,
                tier: nil,
                summary: "No completed tests are available for this category yet. Complete a test to establish a personal baseline.",
                diagnostics: [],
                completedTests: 0
            )
        }

        let tier = overallTier(for: samples)
        let primaryAverage = samples.map(\.primaryMetric).reduce(0, +) / Double(samples.count)
        let secondaryValues = samples.compactMap(\.secondaryMetric)
        let secondaryAverage = secondaryValues.isEmpty
            ? nil
            : secondaryValues.reduce(0, +) / Double(secondaryValues.count)

        return CategoryInsight(
            category: category,
            tier: tier,
            summary: summary(for: category, tier: tier),
            diagnostics: diagnostics(
                for: category,
                tier: tier,
                primaryAverage: primaryAverage,
                secondaryAverage: secondaryAverage,
                sampleCount: samples.count
            ),
            completedTests: samples.count
        )
    }

    private static func overallTier(for samples: [CategorySample]) -> PerformanceTier {
        let averageScore = samples.map { Double($0.tier.score) }.reduce(0, +) / Double(samples.count)

        if averageScore >= 1.5 {
            return .optimal
        } else if averageScore >= 0.5 {
            return .average
        } else {
            return .developing
        }
    }

    private static func summary(
        for category: CognitiveCategory,
        tier: PerformanceTier
    ) -> String {
        switch (category, tier) {
        case (.attentionControl, .optimal):
            "Your recorded attention-control sessions show consistently strong accuracy with efficient response timing. This pattern indicates a reliable balance of focus and speed in the tasks completed here."
        case (.attentionControl, .average):
            "Your recorded attention-control sessions show a steady foundation, with either accuracy or response timing leaving room to become more consistent. Repeating the test under similar conditions can clarify your baseline."
        case (.attentionControl, .developing):
            "Your recorded attention-control sessions show that accuracy and response timing are still developing in this task. Use these results as a personal starting point and look for gradual consistency across future sessions."
        case (.memory, .optimal):
            "Your recorded memory sessions show a strong ability to reproduce longer block sequences. This indicates a reliable working-memory performance pattern in the tasks completed here."
        case (.memory, .average):
            "Your recorded memory sessions show a stable working-memory foundation, with room to build consistency at longer sequence lengths. Additional sessions can help establish a clearer personal baseline."
        case (.memory, .developing):
            "Your recorded memory sessions show that longer sequence recall is still developing in this task. Treat this as a personal starting point and watch for steady changes with repeated practice."
        case (.processingSpeed, .optimal):
            "Your recorded processing-speed sessions show fast average and peak response times. This indicates a reliable speed pattern in the tasks completed here."
        case (.processingSpeed, .average):
            "Your recorded processing-speed sessions show a steady response-time foundation, with room for greater consistency. Additional sessions under similar conditions can clarify your personal baseline."
        case (.processingSpeed, .developing):
            "Your recorded processing-speed sessions show that response timing is still developing in this task. Use the results as a personal starting point and look for gradual changes across future sessions."
        }
    }

    private static func diagnostics(
        for category: CognitiveCategory,
        tier: PerformanceTier,
        primaryAverage: Double,
        secondaryAverage: Double?,
        sampleCount: Int
    ) -> [String] {
        let sessionText = sampleCount == 1 ? "1 completed session" : "\(sampleCount) completed sessions"

        switch category {
        case .attentionControl:
            return [
                "Overall tier: \(tier.title), based on the combined accuracy and response-time rules.",
                "Average accuracy: \(primaryAverage.formatted(.number.precision(.fractionLength(1))))%.",
                "Average response time: \((secondaryAverage ?? 0).formatted(.number.precision(.fractionLength(0)))) ms across \(sessionText)."
            ]
        case .memory:
            return [
                "Overall tier: \(tier.title), based on blocks correct.",
                "Average best span: \(primaryAverage.formatted(.number.precision(.fractionLength(1)))) blocks.",
                "History reviewed: \(sessionText)."
            ]
        case .processingSpeed:
            return [
                "Overall tier: \(tier.title), based on average and fastest logged response times.",
                "Average response time: \(primaryAverage.formatted(.number.precision(.fractionLength(0)))) ms.",
                "Average fastest response: \((secondaryAverage ?? 0).formatted(.number.precision(.fractionLength(0)))) ms across \(sessionText)."
            ]
        }
    }

    private static func percentage(score: Int, total: Int) -> Double? {
        guard total > 0 else { return nil }
        return Double(score) / Double(total) * 100
    }
}
