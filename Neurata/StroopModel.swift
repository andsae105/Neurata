//
//  StroopModel.swift
//  Neurata
//
//  Created by Andres Saenz on 10/17/26.
//

import SwiftUI

enum StroopColor: String, CaseIterable, Codable {
    case red = "RED"
    case blue = "BLUE"
    case green = "GREEN"
    case yellow = "YELLOW"
    
    var displayColor: Color {
        switch self {
        case .red: return .red
        case .blue: return .blue
        case .green: return .green
        case .yellow: return .yellow
        }
    }
}

struct StroopResult: Identifiable, Codable {
    var id: UUID = UUID()
    let date: Date
    var testName: String = "Stroop Test"
    let score: Int
    let totalQuestions: Int
    let averageResponseTime: TimeInterval
    var tagline: String = ""
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter.string(from: date)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, date, testName, score, totalQuestions, averageResponseTime, tagline
    }
    
    init(id: UUID = UUID(), date: Date = Date(), testName: String = "Stroop Test", score: Int, totalQuestions: Int, averageResponseTime: TimeInterval, tagline: String = "") {
        self.id = id
        self.date = date
        self.testName = testName
        self.score = score
        self.totalQuestions = totalQuestions
        self.averageResponseTime = averageResponseTime
        self.tagline = tagline
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.date = try container.decode(Date.self, forKey: .date)
        self.testName = try container.decodeIfPresent(String.self, forKey: .testName) ?? "Stroop Test"
        self.score = try container.decode(Int.self, forKey: .score)
        self.totalQuestions = try container.decode(Int.self, forKey: .totalQuestions)
        self.averageResponseTime = try container.decode(TimeInterval.self, forKey: .averageResponseTime)
        self.tagline = try container.decodeIfPresent(String.self, forKey: .tagline) ?? ""
    }
}

struct CorsiResult: Identifiable, Codable {
    var id: UUID = UUID()
    let date: Date
    var testName: String = "Corsi Memory Test"
    let memorySpan: Int
    let correctTrials: Int
    let totalTrials: Int
    var tagline: String = ""
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter.string(from: date)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, date, testName, memorySpan, correctTrials, totalTrials, tagline
    }
    
    init(id: UUID = UUID(), date: Date = Date(), testName: String = "Corsi Memory Test", memorySpan: Int, correctTrials: Int, totalTrials: Int, tagline: String = "") {
        self.id = id
        self.date = date
        self.testName = testName
        self.memorySpan = memorySpan
        self.correctTrials = correctTrials
        self.totalTrials = totalTrials
        self.tagline = tagline
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.date = try container.decode(Date.self, forKey: .date)
        self.testName = try container.decodeIfPresent(String.self, forKey: .testName) ?? "Corsi Memory Test"
        self.memorySpan = try container.decode(Int.self, forKey: .memorySpan)
        self.correctTrials = try container.decode(Int.self, forKey: .correctTrials)
        self.totalTrials = try container.decode(Int.self, forKey: .totalTrials)
        self.tagline = try container.decodeIfPresent(String.self, forKey: .tagline) ?? ""
    }
}

struct ReactionTimeResult: Identifiable, Codable {
    var id: UUID = UUID()
    let date: Date
    var testName: String = "Reaction Time Test"
    let averageReactionTime: Double // in milliseconds
    let fastestReactionTime: Double // in milliseconds
    let totalTrials: Int
    var tagline: String = ""
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter.string(from: date)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, date, testName, averageReactionTime, fastestReactionTime, totalTrials, tagline
    }
    
    init(id: UUID = UUID(), date: Date = Date(), testName: String = "Reaction Time Test", averageReactionTime: Double, fastestReactionTime: Double, totalTrials: Int = 3, tagline: String = "") {
        self.id = id
        self.date = date
        self.testName = testName
        self.averageReactionTime = averageReactionTime
        self.fastestReactionTime = fastestReactionTime
        self.totalTrials = totalTrials
        self.tagline = tagline
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.date = try container.decode(Date.self, forKey: .date)
        self.testName = try container.decodeIfPresent(String.self, forKey: .testName) ?? "Reaction Time Test"
        self.averageReactionTime = try container.decode(Double.self, forKey: .averageReactionTime)
        self.fastestReactionTime = try container.decode(Double.self, forKey: .fastestReactionTime)
        self.totalTrials = try container.decodeIfPresent(Int.self, forKey: .totalTrials) ?? 3
        self.tagline = try container.decodeIfPresent(String.self, forKey: .tagline) ?? ""
    }
}

struct FullAssessmentResult: Identifiable, Codable {
    var id: UUID = UUID()
    let date: Date
    var testName: String = "Full Assessment"
    let stroopScore: Int
    let stroopTotal: Int
    let stroopAverageResponseTime: TimeInterval
    let memorySpan: Int
    let memoryCorrectTrials: Int
    let memoryTotalTrials: Int
    let reactionAverageTime: Double
    let reactionFastestTime: Double
    var tagline: String = ""
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        return formatter.string(from: date)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, date, testName, stroopScore, stroopTotal, stroopAverageResponseTime, memorySpan, memoryCorrectTrials, memoryTotalTrials, reactionAverageTime, reactionFastestTime, tagline
    }
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        testName: String = "Full Assessment",
        stroopScore: Int,
        stroopTotal: Int,
        stroopAverageResponseTime: TimeInterval,
        memorySpan: Int,
        memoryCorrectTrials: Int,
        memoryTotalTrials: Int,
        reactionAverageTime: Double,
        reactionFastestTime: Double,
        tagline: String = ""
    ) {
        self.id = id
        self.date = date
        self.testName = testName
        self.stroopScore = stroopScore
        self.stroopTotal = stroopTotal
        self.stroopAverageResponseTime = stroopAverageResponseTime
        self.memorySpan = memorySpan
        self.memoryCorrectTrials = memoryCorrectTrials
        self.memoryTotalTrials = memoryTotalTrials
        self.reactionAverageTime = reactionAverageTime
        self.reactionFastestTime = reactionFastestTime
        self.tagline = tagline
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.date = try container.decode(Date.self, forKey: .date)
        self.testName = try container.decodeIfPresent(String.self, forKey: .testName) ?? "Full Assessment"
        self.stroopScore = try container.decode(Int.self, forKey: .stroopScore)
        self.stroopTotal = try container.decode(Int.self, forKey: .stroopTotal)
        self.stroopAverageResponseTime = try container.decode(TimeInterval.self, forKey: .stroopAverageResponseTime)
        self.memorySpan = try container.decode(Int.self, forKey: .memorySpan)
        self.memoryCorrectTrials = try container.decode(Int.self, forKey: .memoryCorrectTrials)
        self.memoryTotalTrials = try container.decode(Int.self, forKey: .memoryTotalTrials)
        self.reactionAverageTime = try container.decode(Double.self, forKey: .reactionAverageTime)
        self.reactionFastestTime = try container.decode(Double.self, forKey: .reactionFastestTime)
        self.tagline = try container.decodeIfPresent(String.self, forKey: .tagline) ?? ""
    }
}

@Observable
class AppDataManager {
    var testResults: [StroopResult] = [] {
        didSet {
            saveResults()
        }
    }
    
    var corsiResults: [CorsiResult] = [] {
        didSet {
            saveCorsiResults()
        }
    }
    
    var reactionResults: [ReactionTimeResult] = [] {
        didSet {
            saveReactionResults()
        }
    }
    
    var fullAssessmentResults: [FullAssessmentResult] = [] {
        didSet {
            saveFullAssessmentResults()
        }
    }
    
    init() {
        loadResults()
        loadCorsiResults()
        loadReactionResults()
        loadFullAssessmentResults()
    }
    
    func addResult(score: Int, total: Int, avgTime: TimeInterval, tagline: String = "") {
        let newResult = StroopResult(date: Date(), score: score, totalQuestions: total, averageResponseTime: avgTime, tagline: tagline)
        testResults.insert(newResult, at: 0)
    }
    
    func addCorsiResult(span: Int, correct: Int, total: Int, tagline: String = "") {
        let result = CorsiResult(
            date: Date(),
            memorySpan: span,
            correctTrials: correct,
            totalTrials: total,
            tagline: tagline
        )
        corsiResults.insert(result, at: 0)
    }
    
    func addReactionResult(avgTime: Double, fastestTime: Double, trials: Int = 3, tagline: String = "") {
        let result = ReactionTimeResult(
            date: Date(),
            averageReactionTime: avgTime,
            fastestReactionTime: fastestTime,
            totalTrials: trials,
            tagline: tagline
        )
        reactionResults.insert(result, at: 0)
    }
    
    func addFullAssessmentResult(
        stroopScore: Int,
        stroopTotal: Int,
        stroopAvgTime: TimeInterval,
        memorySpan: Int,
        memoryCorrect: Int,
        memoryTotal: Int,
        reactionAvgTime: Double,
        reactionFastestTime: Double,
        tagline: String = ""
    ) {
        let result = FullAssessmentResult(
            date: Date(),
            stroopScore: stroopScore,
            stroopTotal: stroopTotal,
            stroopAverageResponseTime: stroopAvgTime,
            memorySpan: memorySpan,
            memoryCorrectTrials: memoryCorrect,
            memoryTotalTrials: memoryTotal,
            reactionAverageTime: reactionAvgTime,
            reactionFastestTime: reactionFastestTime,
            tagline: tagline
        )
        fullAssessmentResults.insert(result, at: 0)
    }
    
    private func saveResults() {
        if let encoded = try? JSONEncoder().encode(testResults) {
            UserDefaults.standard.set(encoded, forKey: "StroopTestResults")
        }
    }
    
    private func loadResults() {
        if let data = UserDefaults.standard.data(forKey: "StroopTestResults"),
           let decoded = try? JSONDecoder().decode([StroopResult].self, from: data) {
            self.testResults = decoded
        }
    }
    
    private func saveCorsiResults() {
        do {
            let data = try JSONEncoder().encode(corsiResults)
            UserDefaults.standard.set(data, forKey: "CorsiResults")
        } catch {
            print("Could not save Corsi results")
        }
    }
    
    private func loadCorsiResults() {
        guard let data = UserDefaults.standard.data(forKey: "CorsiResults") else {
            return
        }
        do {
            corsiResults = try JSONDecoder().decode([CorsiResult].self, from: data)
        } catch {
            print("Could not load Corsi results")
        }
    }
    
    private func saveReactionResults() {
        do {
            let data = try JSONEncoder().encode(reactionResults)
            UserDefaults.standard.set(data, forKey: "ReactionTimeResults")
        } catch {
            print("Could not save Reaction results")
        }
    }
    
    private func loadReactionResults() {
        guard let data = UserDefaults.standard.data(forKey: "ReactionTimeResults") else {
            return
        }
        do {
            reactionResults = try JSONDecoder().decode([ReactionTimeResult].self, from: data)
        } catch {
            print("Could not load Reaction results")
        }
    }
    
    private func saveFullAssessmentResults() {
        do {
            let data = try JSONEncoder().encode(fullAssessmentResults)
            UserDefaults.standard.set(data, forKey: "FullAssessmentResults")
        } catch {
            print("Could not save Full Assessment results")
        }
    }
    
    private func loadFullAssessmentResults() {
        guard let data = UserDefaults.standard.data(forKey: "FullAssessmentResults") else {
            return
        }
        do {
            fullAssessmentResults = try JSONDecoder().decode([FullAssessmentResult].self, from: data)
        } catch {
            print("Could not load Full Assessment results")
        }
    }
}
