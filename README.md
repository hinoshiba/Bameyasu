# Bameyasu — 場の目安。仕事環境を、測って整える。

Bameyasuは、iPhoneを使って仕事環境の改善点を約60秒で見つける、オンデバイスのSwiftUIアプリです。光、音、机の揺れ、姿勢と配置を順に確認し、「まず直す1つ」を提案します。

名前は「場（BA）の目安（MEYASU）」に由来し、読みは「バメヤス」です。推定値を認証済み測定値に見せず、改善判断の参考を届けるという製品姿勢を表します。商品名、識別子、表記ルールと重複・近似調査は[ブランド監査](docs/BRAND_AUDIT.md)、OSSライセンスと商標の境界は[商標ポリシー](TRADEMARKS.md)を参照してください。

> [!IMPORTANT]
> Bameyasuは医療機器、校正済み照度計・騒音計、法定作業環境測定器ではありません。表示には推定値とBameyasu独自の目安が含まれます。診断、治療、疾病予防、専門測定、法令適合の証明には使用できません。

## 特徴

- 背面カメラの露出情報と相対輝度から、作業面の明るさと明暗差を推定
- マイク入力へA特性フィルターを適用し、音量の参考値をリアルタイム解析
- Core Motionで机の揺れと傾きを確認
- 厚生労働省、e-Gov、NIOSH、OSHAの一次情報に基づく姿勢・配置チェック
- 50分のフォーカスタイマーと10分の作業休止ガイド
- 履歴と変化のチャート
- 画像、映像、音声、生のセンサーデータを保存・送信しないオンデバイス設計
- 日本語／英語、Dynamic Type、VoiceOver、Reduce Motion対応

## 測定の誠実さ

iPhoneの内蔵環境光センサーは、一般の商用アプリからlux値を取得できません。Bameyasuの照度はカメラ露出からの推定です。また、iPhoneマイクの生値はdBFSであり、物理的なdBAではありません。BameyasuはA特性処理と任意の比較校正を用意しますが、校正前は`参考 dB*`と表示し、総合値から除外します。

温度、湿度、CO₂、CO、PM2.5、VOC、ホルムアルデヒド、気流、UVはiPhone単体で信頼できる値を取得できないため、推測しません。

詳しい計算、閾値、限界は[METHODOLOGY.md](METHODOLOGY.md)、根拠は[SOURCES.md](SOURCES.md)を参照してください。

## 必要環境

- iOS 17以降
- iPhone
- Xcode 16以降
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)

ランタイムの外部パッケージ依存はありません。

## ビルド

```bash
brew install xcodegen
./build.sh "iPhone 17 Pro"
```

テスト:

```bash
xcodegen generate
xcodebuild \
  -project Bameyasu.xcodeproj \
  -scheme Bameyasu \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' \
  test CODE_SIGNING_ALLOWED=NO
```

`project.yml`がプロジェクト設定の正本です。`Bameyasu.xcodeproj`は生成物で、リポジトリには含めません。

通常のSimulatorビルドとCIは署名不要で、`CODE_SIGNING_ALLOWED=NO`を維持します。同一Developer Teamの配布identityは承認済みKeychain等から再利用し、秘密鍵や証明書バンドルをリポジトリへ置きません。配布経路ごとの証明書区分、保管境界、事故対応は[コード署名ポリシー](docs/CODE_SIGNING.md)を参照してください。

## 構成

```text
Bameyasu/
├── App/           エントリポイント、デザイン、日英表示
├── Models/        測定結果、根拠情報
├── Services/      カメラ、音、モーション、評価、履歴
├── ViewModels/    60秒チェックの状態機械
├── Views/         ホーム、検査、結果、履歴、ガイド、設定
└── Resources/     Privacy Manifest、権限文言、アセット
```

設計の詳細は[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)を参照してください。

## プライバシーとライセンス

- [プライバシーポリシー](PRIVACY.md)
- [利用上の注意](TERMS.md)
- [第三者通知](THIRD_PARTY_NOTICES.txt)
- [ライセンス監査](docs/LICENSE_AUDIT.md)
- [ブランド監査](docs/BRAND_AUDIT.md)
- [コード署名ポリシー](docs/CODE_SIGNING.md)
- [商標ポリシー](TRADEMARKS.md)
- [セキュリティポリシー](SECURITY.md)

Bameyasuのソースコードは[MIT License](LICENSE)です。MITは商用販売を含む利用を許可します。App Storeで配布する署名済みバイナリを有料販売しながら、同じソースをOSSとして公開できます。製品名、ロゴ、アイコン等の商標利用はMITの許諾対象ではありません。

## Contributing

[CONTRIBUTING.md](CONTRIBUTING.md)と[CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)をご確認ください。一般的な問い合わせとセキュリティ上の報告先は[support@hinoshiba.com](mailto:support@hinoshiba.com)です。セキュリティ上の問題は公開Issueへ投稿せず、[SECURITY.md](SECURITY.md)もご確認ください。

---

## English

Bameyasu is an on-device SwiftUI app that helps people review light, sound, desk vibration, and ergonomics in about 60 seconds. It is a wellness and educational tool—not a medical device, calibrated instrument, or compliance meter. See [METHODOLOGY.md](METHODOLOGY.md), [PRIVACY.md](PRIVACY.md), and [TERMS.md](TERMS.md).
