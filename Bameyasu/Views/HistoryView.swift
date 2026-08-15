import Charts
import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var history: HistoryStore

    var body: some View {
        NavigationStack {
            ZStack {
                WorkspaceBackground()
                if history.assessments.isEmpty {
                    ContentUnavailableView {
                        Label(L10n.text("まだ記録がありません", "No history yet"), systemImage: "chart.xyaxis.line")
                    } description: {
                        Text(L10n.text("仕事場をチェックすると、改善前後をここで比べられます。", "Run a workspace check to compare before and after."))
                    }
                } else {
                    List {
                        Section {
                            historyChart
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 16, trailing: 16))
                        }

                        Section(L10n.text("すべてのチェック", "All checks")) {
                            ForEach(history.assessments) { assessment in
                                NavigationLink {
                                    HistoryDetailView(assessment: assessment)
                                } label: {
                                    HStack(spacing: 13) {
                                        ZStack {
                                            Circle()
                                                .fill((assessment.hasSufficientCoverage ? WorkspaceColor.score(assessment.score) : Color.secondary).opacity(0.13))
                                            Text(assessment.hasSufficientCoverage ? "\(assessment.score)" : "—")
                                                .font(.headline.monospacedDigit())
                                                .foregroundStyle(assessment.hasSufficientCoverage ? WorkspaceColor.score(assessment.score) : Color.secondary)
                                        }
                                        .frame(width: 48, height: 48)

                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(assessment.measuredAt, format: .dateTime.year().month().day().hour().minute())
                                                .font(.subheadline.weight(.semibold))
                                            Text(assessment.recommendations.first?.title ?? L10n.text("改善項目なし", "No action needed"))
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                                .lineLimit(1)
                                        }
                                    }
                                }
                            }
                            .onDelete(perform: history.delete)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle(L10n.text("記録", "History"))
        }
    }

    private var historyChart: some View {
        let scored = Array(history.assessments.filter(\.hasSufficientCoverage).prefix(14).reversed())
        return VStack(alignment: .leading, spacing: 12) {
            Text(L10n.text("整い度の変化", "Readiness over time"))
                .font(.headline)
            if scored.isEmpty {
                Text(L10n.text("光と姿勢を確認した記録ができると、ここに変化を表示します。", "Complete light and ergonomics checks to see a trend here."))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 100, alignment: .center)
            } else {
                Chart(scored) { assessment in
                    LineMark(
                        x: .value(L10n.text("日時", "Date"), assessment.measuredAt),
                        y: .value(L10n.text("整い度", "Readiness"), assessment.score)
                    )
                    .foregroundStyle(WorkspaceColor.ember)
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value(L10n.text("日時", "Date"), assessment.measuredAt),
                        y: .value(L10n.text("整い度", "Readiness"), assessment.score)
                    )
                    .foregroundStyle(WorkspaceColor.score(assessment.score))
                }
                .chartYScale(domain: 0...100)
                .chartYAxis {
                    AxisMarks(values: [0, 50, 100])
                }
                .frame(height: 180)
                .accessibilityLabel(L10n.text("直近14回の環境の整い度", "Workspace readiness for the latest 14 checks"))
            }
        }
        .workspaceCard()
    }
}

private struct HistoryDetailView: View {
    let assessment: EnvironmentAssessment

    var body: some View {
        ZStack {
            WorkspaceBackground()
            ScrollView {
                VStack(spacing: 18) {
                    if assessment.hasSufficientCoverage {
                        ScoreOrb(score: assessment.score, diameter: 148)
                    } else {
                        InsufficientCoverageOrb(diameter: 148)
                    }
                    Text(assessment.measuredAt, format: .dateTime.year().month().day().hour().minute())
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    ForEach(assessment.metrics) { MetricCard(metric: $0) }
                    Text(L10n.formatted("評価アルゴリズム v%@", "Scoring algorithm v%@", assessment.algorithmVersion))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .padding(20)
            }
        }
        .navigationTitle(L10n.text("チェック結果", "Check result"))
        .navigationBarTitleDisplayMode(.inline)
    }
}
