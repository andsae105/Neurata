//
//  StroopModel.swift
//  Neurata
//
//  Created by Andres Saenz on 10/17/26.
//
import SwiftUI

// 1. Color Data Model
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

// 2. Individual Test Record Model
struct StroopResult: Identifiable, Codable {
    var id = UUID()
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
}

// 3. Central Shared Data Engine
@Observable
class AppDataManager {
    var testResults: [StroopResult] = [] {
        didSet {
            saveResults()
        }
    }
    
    init() {
        loadResults()
    }
    
    func addResult(score: Int, total: Int, avgTime: TimeInterval) {
        let newResult = StroopResult(date: Date(), score: score, totalQuestions: total, averageResponseTime: avgTime)
        testResults.insert(newResult, at: 0) // Newest tests appear at the top
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
}

