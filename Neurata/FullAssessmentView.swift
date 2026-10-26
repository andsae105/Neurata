//
//  FullAssessmentView.swift
//  Neurata
//
//  Created by Andres Saenz on 10/25/26.
//

import SwiftUI

enum AssessmentStep: Equatable {
    case attention
    case attentionTransition
    case memory
    case memoryTransition
    case processingSpeed
    case summary
    
    var stepNumber: Int {
        switch self {
        case .attention, .attentionTransition: return 1
        case .memory, .memoryTransition: return 2
        case .processingSpeed: return 3
        case .summary: return 3
        }
    }
}

struct FullAssessmentView: View {
    @Environment(AppDataManager.self) private var dataManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentStep: AssessmentStep = .attention
    
    @State private var stroopScore: Int = 0
    @State private var stroopTotal: Int = 10
    @State private var stroopAvgTime: TimeInterval = 0.0
    
    @State private var memorySpan: Int = 0
    @State private var memoryCorrect: Int = 0
    @State private var memoryTotal: Int = 0
    
    @State private var reactionAvgTime: Double = 0.0
    @State private var reactionFastestTime: Double = 0.0
    
    @State private var savedResultId: UUID? = nil
    @State private var personalNote: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            if currentStep != .summary {
                assessmentHeader
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
            }
            
            Group {
                switch currentStep {
                case .attention:
                    StroopTestView(
                        isFullAssessment: true,
                        onComplete: { score, total, avgTime in
                            self.stroopScore = score
                            self.stroopTotal = total
                            self.stroopAvgTime = avgTime
                            withAnimation(.easeInOut) {
                                self.currentStep = .attentionTransition
                            }
                        }
                    )
                    
                case .attentionTransition:
                    stepTransitionView(
                        title: "Attention Control Complete",
                        stepSubtitle: "Test 1 of 3 Finished",
                        icon: "checkmark.circle.fill",
                        iconColor: .orange,
                        metric1Title: "Accuracy",
                        metric1Value: "\(Int((Double(stroopScore) / Double(stroopTotal)) * 100))% (\(stroopScore)/\(stroopTotal))",
                        metric2Title: "Avg Response",
                        metric2Value: "\(Int(stroopAvgTime * 1000)) ms",
                        nextTestTitle: "Memory Test",
                        nextTestSubtitle: "Corsi Block-Tapping Test",
                        buttonText: "Continue to Memory Test →",
                        action: {
                            withAnimation(.easeInOut) {
                                self.currentStep = .memory
                            }
                        }
                    )
                    
                case .memory:
                    MemoryTestScreen(
                        isFullAssessment: true,
                        onComplete: { span, correct, total in
                            self.memorySpan = span
                            self.memoryCorrect = correct
                            self.memoryTotal = total
                            withAnimation(.easeInOut) {
                                self.currentStep = .memoryTransition
                            }
                        }
                    )
                    
                case .memoryTransition:
                    stepTransitionView(
                        title: "Memory Test Complete",
                        stepSubtitle: "Test 2 of 3 Finished",
                        icon: "checkmark.circle.fill",
                        iconColor: .green,
                        metric1Title: "Memory Span",
                        metric1Value: "\(memorySpan) Blocks",
                        metric2Title: "Correct Trials",
                        metric2Value: "\(memoryCorrect) of \(memoryTotal)",
                        nextTestTitle: "Processing Speed",
                        nextTestSubtitle: "Reaction Time Test",
                        buttonText: "Continue to Processing Speed →",
                        action: {
                            withAnimation(.easeInOut) {
                                self.currentStep = .processingSpeed
                            }
                        }
                    )
                    
                case .processingSpeed:
                    ReactionTimeTestView(
                        isFullAssessment: true,
                        onComplete: { avgTime, fastestTime in
                            self.reactionAvgTime = avgTime
                            self.reactionFastestTime = fastestTime
                            saveAssessmentResults()
                            withAnimation(.easeInOut) {
                                self.currentStep = .summary
                            }
                        }
                    )
                    
                case .summary:
                    assessmentSummaryView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle(navigationTitleText)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var navigationTitleText: String {
        switch currentStep {
        case .attention, .attentionTransition:
            return "1. Attention Control"
        case .memory, .memoryTransition:
            return "2. Memory"
        case .processingSpeed:
            return "3. Processing Speed"
        case .summary:
            return "Assessment Results"
        }
    }
    
    private var assessmentHeader: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                stepIndicatorPill(step: 1, name: "Attention", color: .orange, isCurrent: currentStep.stepNumber == 1, isCompleted: currentStep.stepNumber > 1)
                stepIndicatorPill(step: 2, name: "Memory", color: .green, isCurrent: currentStep.stepNumber == 2, isCompleted: currentStep.stepNumber > 2)
                stepIndicatorPill(step: 3, name: "Speed", color: .purple, isCurrent: currentStep.stepNumber == 3, isCompleted: currentStep == .summary)
            }
        }
    }
    
    private func stepIndicatorPill(step: Int, name: String, color: Color, isCurrent: Bool, isCompleted: Bool) -> some View {
        HStack(spacing: 4) {
            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.caption2.bold())
            } else {
                Text("\(step)")
                    .font(.caption2.bold())
            }
            Text(name)
                .font(.caption.weight(isCurrent ? .bold : .regular))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity)
        .background {
            if isCurrent {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.18))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(color, lineWidth: 1.5)
                    }
            } else if isCompleted {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.secondary.opacity(0.12))
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.secondary.opacity(0.06))
            }
        }
        .foregroundColor(isCurrent ? color : (isCompleted ? .primary : .secondary))
    }
    
    private func stepTransitionView(
        title: String,
        stepSubtitle: String,
        icon: String,
        iconColor: Color,
        metric1Title: String,
        metric1Value: String,
        metric2Title: String,
        metric2Value: String,
        nextTestTitle: String,
        nextTestSubtitle: String,
        buttonText: String,
        action: @escaping () -> Void
    ) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 20)
                
                Image(systemName: icon)
                    .font(.system(size: 70))
                    .foregroundColor(iconColor)
                
                VStack(spacing: 6) {
                    Text(title)
                        .font(.title2)
                        .bold()
                    
                    Text(stepSubtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(metric1Title)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(metric1Value)
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(metric2Title)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(metric2Value)
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("UP NEXT")
                        .font(.caption2.bold())
                        .foregroundColor(.gray)
                    
                    Text(nextTestTitle)
                        .font(.headline)
                    
                    Text(nextTestSubtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(14)
                .padding(.horizontal)
                
                Button(action: action) {
                    Text(buttonText)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 40)
                .padding(.top, 10)
                
                Spacer(minLength: 20)
            }
        }
    }
    
    private var assessmentSummaryView: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 70))
                        .foregroundColor(.red)
                    
                    Text("Full Assessment Complete")
                        .font(.title)
                        .bold()
                    
                    Text("Your results have been saved to the Test Library")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 10)
                
                VStack(spacing: 14) {
                    summaryRow(
                        title: "Attention Control (Stroop)",
                        color: .orange,
                        mainMetric: "\(Int((Double(stroopScore) / Double(stroopTotal)) * 100))%",
                        details: "Score: \(stroopScore)/\(stroopTotal) • Avg: \(Int(stroopAvgTime * 1000)) ms"
                    )
                    
                    Divider()
                    
                    summaryRow(
                        title: "Memory (Corsi Block)",
                        color: .green,
                        mainMetric: "\(memorySpan) Blocks",
                        details: "Correct Trials: \(memoryCorrect)/\(memoryTotal)"
                    )
                    
                    Divider()
                    
                    summaryRow(
                        title: "Processing Speed (Reaction)",
                        color: .purple,
                        mainMetric: "\(Int(reactionAvgTime)) ms",
                        details: "Fastest: \(Int(reactionFastestTime)) ms • 3 trials"
                    )
                }
                .padding(18)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(18)
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Personal Note:")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .textCase(.uppercase)
                    
                    TextField("e.g., 'feeling alert' or 'after morning coffee'", text: $personalNote)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: personalNote) { _, newValue in
                            if let id = savedResultId,
                               let index = dataManager.fullAssessmentResults.firstIndex(where: { $0.id == id }) {
                                dataManager.fullAssessmentResults[index].tagline = newValue
                            }
                        }
                }
                .padding(.horizontal)
                
                VStack(spacing: 12) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Finish & View Tests")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(14)
                    }
                    
                    Button(action: restartAssessment) {
                        Text("Retake Full Assessment")
                            .font(.subheadline.bold())
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
            }
        }
    }
    
    private func summaryRow(title: String, color: Color, mainMetric: String, details: String) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(color)
                Text(details)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }
            Spacer()
            Text(mainMetric)
                .font(.title3.bold())
                .foregroundColor(color)
        }
    }
    
    private func saveAssessmentResults() {
        guard savedResultId == nil else { return }
        
        let newResult = FullAssessmentResult(
            stroopScore: stroopScore,
            stroopTotal: stroopTotal,
            stroopAverageResponseTime: stroopAvgTime,
            memorySpan: memorySpan,
            memoryCorrectTrials: memoryCorrect,
            memoryTotalTrials: memoryTotal,
            reactionAverageTime: reactionAvgTime,
            reactionFastestTime: reactionFastestTime,
            tagline: personalNote
        )
        savedResultId = newResult.id
        dataManager.fullAssessmentResults.insert(newResult, at: 0)
    }
    
    private func restartAssessment() {
        stroopScore = 0
        stroopTotal = 10
        stroopAvgTime = 0.0
        memorySpan = 0
        memoryCorrect = 0
        memoryTotal = 0
        reactionAvgTime = 0.0
        reactionFastestTime = 0.0
        savedResultId = nil
        personalNote = ""
        currentStep = .attention
    }
}

#Preview {
    NavigationStack {
        FullAssessmentView()
            .environment(AppDataManager())
    }
}
