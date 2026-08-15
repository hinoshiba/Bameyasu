import SwiftUI

struct AssessmentResultView: View {
    let assessment: EnvironmentAssessment
    let done: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                Group {
                    if assessment.hasSufficientCoverage {
                        ScoreOrb(score: assessment.score)
                    } else {
                        InsufficientCoverageOrb(diameter: 176)
                    }
                }
                .padding(.top, 18)

                VStack(spacing: 7) {
                    Text(resultTitle)
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                    Text(L10n.text(
                        "確認できた項目によるBameyasu独自評価です。健康・安全や法令適合を保証する点数ではありません。",
                        "This is Bameyasu's own score for checked items. It does not guarantee health, safety, or legal compliance."
                    ))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                }

                if let first = assessment.recommendations.first {
                    VStack(alignment: .leading, spacing: 9) {
                        Label(L10n.text("まず直す1つ", "Fix this first"), systemImage: "arrow.up.right.circle.fill")
                            .font(.caption.bold())
                            .foregroundStyle(WorkspaceColor.ember)
                        Text(first.title)
                            .font(.title3.bold())
                        Text(first.action)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .workspaceCard()
                }

                VStack(spacing: 12) {
                    ForEach(assessment.metrics) { metric in
                        MetricCard(metric: metric)
                    }
                }

                VStack(spacing: 10) {
                    Button(action: done) {
                        Text(L10n.text("記録して完了", "Save and finish"))
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(WorkspaceColor.ember)

                    ShareLink(item: shareText) {
                        Label(L10n.text("結果を共有", "Share result"), systemImage: "square.and.arrow.up")
                    }
                    .font(.subheadline)
                }
            }
            .padding(20)
        }
    }

    private var resultTitle: String {
        guard assessment.hasSufficientCoverage else {
            return L10n.text("判定材料が不足しています", "Not enough information to score")
        }
        switch assessment.score {
        case 85...: return L10n.text("この調子で維持しましょう", "Keep this setup going")
        case 65..<85: return L10n.text("あと少し、働きやすくできます", "A few tweaks can make it better")
        default: return L10n.text("まず1つ整えましょう", "Start with one improvement")
        }
    }

    private var shareText: String {
        let recommendation = assessment.recommendations.first?.title ?? ""
        guard assessment.hasSufficientCoverage else {
            return L10n.text(
                "Bameyasuで仕事環境を部分チェック。まずは「\(recommendation)」 #Bameyasu",
                "I partially checked my workspace with Bameyasu. First action: \(recommendation) #Bameyasu"
            )
        }
        return L10n.text(
            "Bameyasuで仕事環境をチェック：環境の整い度 \(assessment.score)。まずは「\(recommendation)」 #Bameyasu",
            "I checked my workspace with Bameyasu: readiness \(assessment.score). First action: \(recommendation) #Bameyasu"
        )
    }
}
