import SwiftUI
import UIKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @AppStorage("soundCalibrationTrim") private var calibrationTrim = 0.0
    @AppStorage("soundCalibrationConfirmed") private var calibrationConfirmed = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle(L10n.text("基準器と比較済み", "Compared with a reference meter"), isOn: $calibrationConfirmed)
                    VStack(alignment: .leading, spacing: 9) {
                        HStack {
                            Text(L10n.text("補正値", "Calibration trim"))
                            Spacer()
                            Text(String(format: "%+.1f dB", calibrationTrim))
                                .monospacedDigit()
                        }
                        Slider(value: $calibrationTrim, in: -20...20, step: 0.5)
                    }
                    Button(L10n.text("補正をリセット", "Reset calibration"), role: .destructive) {
                        calibrationTrim = 0
                        calibrationConfirmed = false
                    }
                } header: {
                    Text(L10n.text("音量の比較校正", "Sound comparison calibration"))
                } footer: {
                    Text(L10n.text(
                        "同じ位置・同じ音で校正済み騒音計と比較し、その差を補正します。比較後も法定測定器の代替にはなりません。",
                        "Compare at the same position and sound with a calibrated meter, then enter the difference. This still does not replace a statutory instrument."
                    ))
                }

                Section(L10n.text("アプリについて", "About the app")) {
                    NavigationLink(L10n.text("プライバシー", "Privacy")) {
                        LegalTextView(kind: .privacy)
                    }
                    NavigationLink(L10n.text("利用上の注意", "Terms and disclaimer")) {
                        LegalTextView(kind: .terms)
                    }
                    NavigationLink(L10n.text("オープンソースライセンス", "Open-source licenses")) {
                        LegalTextView(kind: .licenses)
                    }
                    Link(L10n.text("サポート", "Support"), destination: URL(string: L10n.text("https://bameyasu.hinoshiba.com/#support", "https://bameyasu.hinoshiba.com/?lang=en#en-support"))!)
                    Link(L10n.text("プライバシーポリシー", "Privacy policy"), destination: URL(string: L10n.text("https://bameyasu.hinoshiba.com/#privacy", "https://bameyasu.hinoshiba.com/?lang=en#en-privacy"))!)
                    Link(L10n.text("ソースコード", "Source code"), destination: URL(string: "https://github.com/hinoshiba/Bameyasu")!)
                }

                Section(L10n.text("権限", "Permissions")) {
                    Button(L10n.text("iPhoneの設定を開く", "Open iPhone Settings")) {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            openURL(url)
                        }
                    }
                }

                Section {
                    Button(L10n.text("説明をもう一度見る", "Show introduction again")) {
                        hasCompletedOnboarding = false
                        dismiss()
                    }
                }

                Section {
                    HStack {
                        Text("Bameyasu")
                        Spacer()
                        Text(versionDisplay)
                            .foregroundStyle(.secondary)
                    }
                } footer: {
                    Text("Copyright © 2026 hinoshiba")
                }
            }
            .navigationTitle(L10n.text("設定", "Settings"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.text("完了", "Done")) { dismiss() }
                }
            }
        }
    }

    private var versionDisplay: String {
        guard
            let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
            !version.isEmpty,
            let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String,
            !build.isEmpty
        else {
            return "—"
        }
        return "\(version) (\(build))"
    }
}

private struct LegalTextView: View {
    enum Kind {
        case privacy
        case terms
        case licenses
    }

    let kind: Kind

    var body: some View {
        ScrollView {
            Text(bodyText)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var title: String {
        switch kind {
        case .privacy: L10n.text("プライバシー", "Privacy")
        case .terms: L10n.text("利用上の注意", "Terms")
        case .licenses: L10n.text("ライセンス", "Licenses")
        }
    }

    private var bodyText: String {
        switch kind {
        case .privacy:
            L10n.text(
                "カメラ・マイク・モーション入力はチェック中にiPhoneで処理し、画像・映像・音声・生のセンサーデータを保存せず、開発者へ送信しません。結果と設定は端末に保存します。履歴は記録画面から、権限はiPhoneの設定から管理できます。購入や外部リンクには各サービスのポリシーが適用されます。support@hinoshiba.comへのメールは、メール事業者を通じて受領し、対応または法令上必要な期間だけ保持します。同じ窓口へ削除を依頼できます。詳細は製品サイトのプライバシーポリシーをご確認ください。",
                "Camera, microphone, and motion input are processed on the iPhone during a check. Images, video, audio, and raw sensor data are not saved or sent to the developer. Results and settings are saved on the device. Manage history in the History screen and permissions in iPhone Settings. Purchases and external links follow the respective service’s policy. Email to support@hinoshiba.com is received through our email provider and retained as needed to respond or meet legal obligations. You may request deletion at the same address. See the product website for the full policy."
            )
        case .terms:
            L10n.text(
                "Bameyasuは仕事環境の改善に役立つ参考情報を提供するウェルネス・教育用ツールです。医療機器、校正済み測定器、法定の作業環境測定器ではありません。表示値は端末、ケース、設置位置、向き、反射、風、周囲の音、校正状態などで変化します。診断、治療、予防、専門測定、法令適合の証明には使用しないでください。症状、強い不快感、危険な音、燃焼ガス等が疑われる場合は、表示値にかかわらずその場を離れ、事業者、産業医、医療機関または有資格の専門家へ相談してください。",
                "Bameyasu is a wellness and educational tool that provides guidance for improving workspaces. It is not a medical device, calibrated instrument, or statutory workplace meter. Values vary with device, case, placement, direction, reflections, wind, ambient sound, and calibration. Do not use it for diagnosis, treatment, prevention, professional measurement, or proof of legal compliance. If symptoms, severe discomfort, hazardous noise, combustion gases, or another danger are suspected, leave the area regardless of the reading and contact an employer, occupational health professional, medical provider, or qualified specialist."
            )
        case .licenses:
            L10n.text(
                "Bameyasu本体\nMIT License — Copyright © 2026 hinoshiba\n\n配布バイナリには第三者のランタイムOSSを同梱していません。SwiftUI、AVFoundation、Core Motion、Charts、SF SymbolsはApple SDKの一部で、各Apple契約に従ってiPhoneアプリ内で使用しています。SF Symbolsはロゴやアプリアイコンには使用していません。XcodeGen（MIT）は開発時だけ使用し、アプリには同梱されません。",
                "Bameyasu\nMIT License — Copyright © 2026 hinoshiba\n\nThe distributed binary bundles no third-party runtime open-source software. SwiftUI, AVFoundation, Core Motion, Charts, and SF Symbols are Apple SDK technologies used in the iPhone app under Apple's terms. SF Symbols are not used as the logo or app icon. XcodeGen (MIT) is a development-time tool and is not included in the app."
            )
        }
    }
}
