import SwiftUI

struct GuidedScanView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var coordinator = ScanCoordinator()
    let completed: (EnvironmentAssessment) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                WorkspaceBackground()

                Group {
                    switch coordinator.stage {
                    case .intro:
                        intro
                    case .light, .noise, .stability:
                        sensorStage
                    case .ergonomics:
                        ergonomics
                    case .result:
                        if let assessment = coordinator.assessment {
                            AssessmentResultView(assessment: assessment) {
                                completed(assessment)
                            }
                        }
                    }
                }
            }
            .navigationTitle(coordinator.stage.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if coordinator.stage != .result {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(L10n.text("閉じる", "Close")) {
                            coordinator.cancel()
                            dismiss()
                        }
                    }
                }
            }
            .alert(
                L10n.text("この項目は未測定です", "This item was not measured"),
                isPresented: Binding(
                    get: { coordinator.presentedError != nil },
                    set: { if !$0 { coordinator.presentedError = nil } }
                )
            ) {
                Button("OK", role: .cancel) { coordinator.presentedError = nil }
            } message: {
                Text(coordinator.presentedError ?? "")
            }
            .onDisappear { coordinator.cancel() }
            .onChange(of: scenePhase) { _, phase in
                if phase != .active {
                    coordinator.cancel()
                }
            }
        }
    }

    private var intro: some View {
        ScrollView {
            VStack(spacing: 28) {
                Spacer(minLength: 20)

                ZStack {
                    Circle()
                        .fill(WorkspaceColor.ember.opacity(0.11))
                        .frame(width: 210, height: 210)
                    Circle()
                        .trim(from: 0.08, to: 0.92)
                        .stroke(
                            AngularGradient(colors: [WorkspaceColor.sun, WorkspaceColor.ember, WorkspaceColor.sky], center: .center),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 165, height: 165)
                    Text("60")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                    Text(L10n.text("秒", "sec"))
                        .font(.caption.bold())
                        .offset(y: 49)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(L10n.text("約60秒", "About 60 seconds"))

                VStack(spacing: 10) {
                    Text(L10n.text("普段の席で、そのまま測る", "Measure at your usual seat"))
                        .font(.title2.bold())
                    Text(L10n.text(
                        "光10秒、音15秒、机8秒のあと、姿勢と配置を確認します。許可しない項目があっても続けられます。",
                        "Check light for 10 seconds, sound for 15, desk for 8, then review your setup. You can continue if a permission is declined."
                    ))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                }

                VStack(spacing: 0) {
                    scanRow(.light, detail: L10n.text("カメラ入力を解析・保存なし", "Live camera analysis; not saved"))
                    Divider().padding(.leading, 46)
                    scanRow(.noise, detail: L10n.text("音量だけを解析・保存なし", "Sound level only; not saved"))
                    Divider().padding(.leading, 46)
                    scanRow(.stability, detail: L10n.text("加速度で揺れを確認", "Vibration via motion sensors"))
                    Divider().padding(.leading, 46)
                    scanRow(.ergonomics, detail: L10n.text("公的ガイドで自己確認", "Self-check with public guidance"))
                }
                .workspaceCard()

                Button {
                    coordinator.begin()
                } label: {
                    Text(L10n.text("チェックを始める", "Start check"))
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(WorkspaceColor.ember)
            }
            .padding(20)
        }
    }

    private func scanRow(_ kind: MetricKind, detail: String) -> some View {
        HStack(spacing: 13) {
            Image(systemName: kind.icon)
                .foregroundStyle(WorkspaceColor.ember)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(kind.title).font(.subheadline.weight(.semibold))
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 10)
    }

    private var sensorStage: some View {
        VStack(spacing: 0) {
            ProgressView(value: coordinator.progress)
                .tint(WorkspaceColor.ember)
                .padding(.horizontal, 20)
                .padding(.top, 8)

            ScrollView {
                VStack(spacing: 26) {
                    sensorVisualization

                    VStack(spacing: 8) {
                        Text(stageHeadline)
                            .font(.title2.bold())
                            .multilineTextAlignment(.center)
                        Text(stageInstruction)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    privacyNote

                    if coordinator.isMeasuring {
                        VStack(spacing: 8) {
                            Text(L10n.formatted("あと %d 秒", "%d seconds left", coordinator.secondsRemaining))
                                .font(.headline.monospacedDigit())
                            ProgressView()
                                .controlSize(.small)
                        }
                    } else {
                        VStack(spacing: 10) {
                            Button {
                                coordinator.measureCurrent()
                            } label: {
                                Label(L10n.text("この項目を測る", "Measure this item"), systemImage: "play.fill")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 13)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(WorkspaceColor.ember)

                            Button(L10n.text("今回はスキップ", "Skip this time")) {
                                coordinator.skipCurrent()
                            }
                            .font(.subheadline)
                        }
                    }
                }
                .padding(20)
            }
        }
    }

    @ViewBuilder
    private var sensorVisualization: some View {
        ZStack {
            Circle()
                .fill(stageColor.opacity(0.11))
                .frame(width: 220, height: 220)
            Circle()
                .stroke(stageColor.opacity(0.18), lineWidth: 1)
                .frame(width: 176, height: 176)
            Circle()
                .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round, dash: [2, 14]))
                .foregroundStyle(stageColor.opacity(0.6))
                .frame(width: 148, height: 148)
                .rotationEffect(.degrees(coordinator.isMeasuring ? 80 : 0))
                .animation(.easeInOut(duration: 1), value: coordinator.isMeasuring)

            VStack(spacing: 8) {
                Image(systemName: coordinator.stage.icon)
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundStyle(stageColor)
                Text(liveValue)
                    .font(.title3.monospacedDigit().bold())
            }
        }
        .padding(.top, 22)
        .accessibilityElement(children: .combine)
    }

    private var stageHeadline: String {
        switch coordinator.stage {
        case .light: L10n.text("白い紙を作業面に置く", "Place white paper on the work surface")
        case .noise: L10n.text("iPhoneを机に置く", "Place iPhone on the desk")
        case .stability: L10n.text("平らに置いて手を離す", "Lay it flat and let go")
        default: ""
        }
    }

    private var stageInstruction: String {
        switch coordinator.stage {
        case .light:
            L10n.text("背面カメラを普段読む書類やキーボードの面へ向けます。照明を直接映さないでください。", "Aim the rear camera at the surface where you read documents or use the keyboard. Do not point directly at a lamp.")
        case .noise:
            L10n.text("普段の音がある状態で静かに待ちます。ケースや指でマイクを塞がないでください。", "Wait quietly with the room in its usual state. Do not cover the microphone with a case or finger.")
        case .stability:
            L10n.text("キーボードを打たず、机に触れない状態の小さな揺れを確認します。", "Avoid typing or touching the desk while Bameyasu checks small vibrations.")
        default: ""
        }
    }

    private var privacyNote: some View {
        Label {
            Text(stagePrivacy)
                .font(.caption)
                .foregroundStyle(.secondary)
        } icon: {
            Image(systemName: "lock.shield.fill")
                .foregroundStyle(WorkspaceColor.mint)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WorkspaceColor.mint.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
    }

    private var stagePrivacy: String {
        switch coordinator.stage {
        case .light: L10n.text("カメラ入力は端末上で解析し、画像・映像は保存も送信もしません。", "Camera input is analyzed on device; images and video are not saved or transmitted.")
        case .noise: L10n.text("音声内容は認識しません。音量を端末上で解析し、音声は保存も送信もしません。", "Bameyasu does not recognize speech. Sound level is analyzed on device; audio is not saved or transmitted.")
        case .stability: L10n.text("モーションデータはこの測定中だけ処理します。", "Motion data is processed only during this check.")
        default: ""
        }
    }

    private var stageColor: Color {
        switch coordinator.stage {
        case .light: WorkspaceColor.sun
        case .noise: WorkspaceColor.sky
        case .stability: WorkspaceColor.mint
        default: WorkspaceColor.ember
        }
    }

    private var liveValue: String {
        switch coordinator.stage {
        case .light:
            guard let value = coordinator.lightMeter.reading.estimatedLux else { return "—" }
            return L10n.formatted("約 %d lx", "~%d lx", Int(value.rounded()))
        case .noise:
            guard let value = coordinator.soundMeter.reading.estimatedDBA else { return "—" }
            return L10n.formatted("参考 %d dB*", "ref. %d dB*", Int(value.rounded()))
        case .stability:
            guard let value = coordinator.motionMeter.reading.vibrationRMS else { return "—" }
            return String(format: "%.3f g", value)
        default:
            return "—"
        }
    }

    private var ergonomics: some View {
        VStack(spacing: 0) {
            ProgressView(value: 0.86)
                .tint(WorkspaceColor.ember)
                .padding(.horizontal, 20)
                .padding(.top, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 7) {
                        Text(L10n.text("いまの姿勢で確認", "Check your current posture"))
                            .font(.title2.bold())
                        Text(L10n.text("当てはまる項目をタップします。未確認は良好として数えません。", "Tap items that are true. Unchecked items are not counted as good."))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    ForEach($coordinator.checks) { $check in
                        Button {
                            check.isSatisfied.toggle()
                        } label: {
                            HStack(alignment: .top, spacing: 13) {
                                Image(systemName: check.isSatisfied ? "checkmark.circle.fill" : "circle")
                                    .font(.title3)
                                    .foregroundStyle(check.isSatisfied ? WorkspaceColor.mint : .secondary)
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(check.title)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.primary)
                                    Text(check.guidance)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.leading)
                                }
                                Spacer(minLength: 0)
                            }
                            .padding(15)
                            .background(Color.primary.opacity(0.045), in: RoundedRectangle(cornerRadius: 17, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .accessibilityValue(check.isSatisfied ? L10n.text("確認済み", "Confirmed") : L10n.text("未確認", "Not confirmed"))
                    }

                    Button {
                        coordinator.finishErgonomics()
                    } label: {
                        Text(L10n.text("結果を見る", "See results"))
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(WorkspaceColor.ember)
                }
                .padding(20)
            }
        }
    }
}
