import Combine
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var history: HistoryStore
    @State private var showingScan = false
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                WorkspaceBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        header

                        if let latest = history.assessments.first {
                            latestCard(latest)
                            if let recommendation = latest.recommendations.first {
                                recommendationCard(recommendation)
                            }
                        } else {
                            emptyHero
                        }

                        Button {
                            showingScan = true
                        } label: {
                            HStack {
                                Image(systemName: "sensor.tag.radiowaves.forward.fill")
                                Text(L10n.text("60秒で仕事場をチェック", "Check your workspace in 60 seconds"))
                                Spacer()
                                Image(systemName: "arrow.right")
                            }
                            .font(.headline)
                            .padding(.vertical, 15)
                            .padding(.horizontal, 18)
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(WorkspaceColor.ember)
                        .controlSize(.large)
                        .accessibilityHint(L10n.text("光、音、机、姿勢の順に確認します", "Checks light, sound, desk, then ergonomics"))

                        FocusTimerCard()

                        unavailableNote
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityLabel(L10n.text("設定", "Settings"))
                }
            }
            .sheet(isPresented: $showingScan) {
                GuidedScanView { assessment in
                    history.add(assessment)
                    showingScan = false
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Bameyasu")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                Text(L10n.text("場の目安。仕事環境を、測って整える。", "A practical reference for a better workspace."))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Circle()
                .fill(
                    RadialGradient(
                        colors: [WorkspaceColor.sun, WorkspaceColor.ember.opacity(0.15)],
                        center: .center,
                        startRadius: 2,
                        endRadius: 28
                    )
                )
                .frame(width: 54, height: 54)
                .overlay(Circle().stroke(WorkspaceColor.sun.opacity(0.3), lineWidth: 1))
                .accessibilityHidden(true)
        }
        .padding(.top, 8)
    }

    private var emptyHero: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundStyle(WorkspaceColor.sun)
                Text(L10n.text("最初のチェック", "Your first check"))
                    .font(.title2.bold())
            }
            Text(L10n.text(
                "普段の席でiPhoneを使い、光・音・机の揺れ・作業姿勢を順に確認します。権限は必要な工程でだけ尋ねます。",
                "Use your iPhone at your usual desk to review light, sound, vibration, and ergonomics. Permissions are requested only when needed."
            ))
            .font(.body)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                ForEach(["sun.max.fill", "waveform", "gyroscope", "figure.seated.side"], id: \.self) { icon in
                    Image(systemName: icon)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundStyle(WorkspaceColor.ember)
                        .background(WorkspaceColor.ember.opacity(0.09), in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .workspaceCard()
    }

    private func latestCard(_ assessment: EnvironmentAssessment) -> some View {
        HStack(spacing: 22) {
            if assessment.hasSufficientCoverage {
                ScoreOrb(score: assessment.score, diameter: 132)
            } else {
                InsufficientCoverageOrb(diameter: 132)
            }

            VStack(alignment: .leading, spacing: 7) {
                Text(L10n.text("最新の仕事場", "Latest workspace"))
                    .font(.headline)
                Text(assessment.measuredAt, format: .dateTime.month().day().hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(assessment.hasSufficientCoverage
                     ? scoreMessage(assessment.score)
                     : L10n.text("判定材料が不足しています", "Not enough information to score"))
                    .font(.subheadline.weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .workspaceCard()
    }

    private func recommendationCard(_ recommendation: Recommendation) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(L10n.text("まず直す1つ", "Fix this first"), systemImage: "arrow.up.right.circle.fill")
                .font(.caption.bold())
                .foregroundStyle(WorkspaceColor.ember)
            Text(recommendation.title)
                .font(.title3.bold())
            Text(recommendation.action)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .workspaceCard()
    }

    private var unavailableNote: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "sensor.fill")
                .foregroundStyle(WorkspaceColor.sky)
            VStack(alignment: .leading, spacing: 4) {
                Text(L10n.text("iPhoneだけでは測れないもの", "What iPhone cannot measure alone"))
                    .font(.subheadline.weight(.semibold))
                Text(L10n.text(
                    "温度・湿度・CO₂・PM2.5・VOCは外部センサーが必要です。Bameyasuは推測して点数に入れません。",
                    "Temperature, humidity, CO₂, PM2.5, and VOCs require external sensors. Bameyasu never guesses or scores them."
                ))
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 4)
    }

    private func scoreMessage(_ score: Int) -> String {
        switch score {
        case 85...: L10n.text("確認できた項目は目安内です", "Checked items are within the guide")
        case 65..<85: L10n.text("少し整えると、もっと働きやすく", "A few adjustments can improve it")
        default: L10n.text("まず1つ、環境を整えましょう", "Start with one practical improvement")
        }
    }
}

struct InsufficientCoverageOrb: View {
    let diameter: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(style: StrokeStyle(lineWidth: 10, dash: [4, 8]))
                .foregroundStyle(.secondary.opacity(0.35))
            VStack(spacing: 2) {
                Text("—")
                    .font(.system(size: diameter * 0.30, weight: .bold, design: .rounded))
                Text(L10n.text("未判定", "unscored"))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: diameter, height: diameter)
        .accessibilityLabel(L10n.text("判定材料が不足しています", "Not enough information to score"))
    }
}

private struct FocusTimerCard: View {
    @State private var endDate: Date?
    @State private var now = Date()
    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var remaining: TimeInterval {
        max(0, endDate?.timeIntervalSince(now) ?? 50 * 60)
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(WorkspaceColor.sky.opacity(0.18), lineWidth: 7)
                Circle()
                    .trim(from: 0, to: CGFloat(remaining / (50 * 60)))
                    .stroke(WorkspaceColor.sky, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Image(systemName: "timer")
                    .foregroundStyle(WorkspaceColor.sky)
            }
            .frame(width: 58, height: 58)

            VStack(alignment: .leading, spacing: 3) {
                Text(L10n.text("50分フォーカス", "50-minute focus"))
                    .font(.headline)
                Text(timeLabel)
                    .font(.title3.monospacedDigit().weight(.semibold))
                Text(L10n.text("終了後は10分、作業から離れましょう", "Take a 10-minute work break afterward"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                if endDate == nil {
                    endDate = Date().addingTimeInterval(50 * 60)
                } else {
                    endDate = nil
                }
            } label: {
                Image(systemName: endDate == nil ? "play.fill" : "stop.fill")
                    .frame(width: 42, height: 42)
            }
            .buttonStyle(.bordered)
            .accessibilityLabel(endDate == nil ? L10n.text("タイマー開始", "Start timer") : L10n.text("タイマー停止", "Stop timer"))
        }
        .workspaceCard()
        .onReceive(ticker) { date in
            now = date
            if let endDate, date >= endDate {
                self.endDate = nil
            }
        }
    }

    private var timeLabel: String {
        let total = Int(remaining)
        return String(format: "%02d:%02d", total / 60, total % 60)
    }
}
