//
//  NeurataTests.swift
//  NeurataTests
//
//  Created by Andres Saenz on 10/16/26.
//

import Testing
import Foundation
@testable import Neurata

@MainActor
struct NeurataTests {

    @Test func testFullAssessmentResultCreation() {
        let manager = AppDataManager()
        let initialCount = manager.fullAssessmentResults.count
        
        manager.addFullAssessmentResult(
            stroopScore: 9,
            stroopTotal: 10,
            stroopAvgTime: 0.65,
            memorySpan: 6,
            memoryCorrect: 5,
            memoryTotal: 6,
            reactionAvgTime: 240,
            reactionFastestTime: 215,
            tagline: "Test assessment"
        )
        
        #expect(manager.fullAssessmentResults.count == initialCount + 1)
        let latest = manager.fullAssessmentResults.first
        #expect(latest?.stroopScore == 9)
        #expect(latest?.memorySpan == 6)
        #expect(latest?.reactionAverageTime == 240)
        #expect(latest?.tagline == "Test assessment")
    }

    @Test func testReactionTimeResultCreation() {
        let manager = AppDataManager()
        let initialCount = manager.reactionResults.count
        
        manager.addReactionResult(
            avgTime: 250,
            fastestTime: 210,
            trials: 3,
            tagline: "Fast reflexes"
        )
        
        #expect(manager.reactionResults.count == initialCount + 1)
        let latest = manager.reactionResults.first
        #expect(latest?.averageReactionTime == 250)
        #expect(latest?.fastestReactionTime == 210)
        #expect(latest?.totalTrials == 3)
    }

    @Test func testInsightEngineNormalizesMetricsByCategory() {
        let insights = InsightEngine.insights(
            stroopResults: [
                StroopResult(score: 18, totalQuestions: 20, averageResponseTime: 0.650)
            ],
            corsiResults: [
                CorsiResult(memorySpan: 6, correctTrials: 4, totalTrials: 5)
            ],
            reactionResults: [
                ReactionTimeResult(averageReactionTime: 280, fastestReactionTime: 230)
            ],
            fullAssessments: []
        )

        #expect(insights.count == 3)
        #expect(insights.first(where: { $0.category == .attentionControl })?.tier == .optimal)
        #expect(insights.first(where: { $0.category == .memory })?.tier == .average)
        #expect(insights.first(where: { $0.category == .processingSpeed })?.tier == .optimal)
    }

    @Test func testInsightEngineUsesPlaceholderForMissingCategoryHistory() {
        let insights = InsightEngine.insights(
            stroopResults: [],
            corsiResults: [],
            reactionResults: [],
            fullAssessments: []
        )

        #expect(insights.allSatisfy { !$0.hasData })
        #expect(insights.allSatisfy { $0.diagnostics.isEmpty })
    }

}
