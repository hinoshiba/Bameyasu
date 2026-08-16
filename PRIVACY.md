# Privacy Policy / プライバシーポリシー

Effective: 2026-08-16

## Summary / 要約

Bameyasu does not collect data from the app. Bameyasu has no account system, advertising, analytics SDK, crash-reporting SDK, or cloud synchronization.

Bameyasuはアプリからデータを収集しません。アカウント、広告、分析SDK、クラッシュ収集SDK、クラウド同期はありません。

## Sensor processing / センサー処理

- Camera input is analyzed live on the device only during the lighting step. Images and video are not saved or transmitted.
- Microphone input is analyzed live on the device only during the sound step. Bameyasu does not perform speech recognition. Audio is not saved or transmitted.
- Motion data is processed live on the device only during the desk-stability step. Raw motion samples are not saved or transmitted.
- カメラ、マイク、モーション入力は、それぞれの測定中だけ端末上でリアルタイム解析します。画像、映像、音声、生のセンサーデータを保存または送信しません。音声認識も行いません。

## Data stored on the device / 端末内に保存する情報

Bameyasu stores completed assessment summaries and user settings in the app sandbox. Assessment history contains the time, calculated metrics, checklist answers, recommendations, and scoring-algorithm version. It does not contain images, audio, raw camera frames, raw microphone samples, contacts, location, identifiers, or advertising data.

完了したチェックの日時、計算済み指標、チェック回答、提案、評価アルゴリズム版と設定をアプリのサンドボックスへ保存します。画像、音声、生のフレーム／サンプル、連絡先、位置情報、広告識別子は含みません。

Users can delete individual history entries in the History tab. Deleting the app removes its sandboxed data. Permissions can be revoked in iPhone Settings.

記録画面で個別に削除できます。アプリを削除するとサンドボックス内のデータも削除されます。権限はiPhoneの設定から撤回できます。

## External links / 外部リンク

Bameyasu does not contact a server by itself. If the user opens an evidence or source-code link, the destination receives normal web-request information such as the IP address and user agent under its own privacy policy.

Bameyasu自身はサーバーへ通信しません。利用者が根拠資料やソースコードの外部リンクを開いた場合、遷移先へIPアドレスやUser-Agent等の通常のアクセス情報が送られ、遷移先のポリシーが適用されます。

## Support communications / サポート通信

If you email [support@hinoshiba.com](mailto:support@hinoshiba.com), the maintainer receives your sender address, email headers, message body, and anything you choose to attach through the email service provider for `hinoshiba.com`. This information is used to reply, provide support, investigate reports, and prevent abuse. It is retained only as long as reasonably necessary for those purposes or legal and security obligations. You may request deletion at the same address, subject to those obligations.

[support@hinoshiba.com](mailto:support@hinoshiba.com)へメールを送ると、管理者は`hinoshiba.com`のメール事業者を通じて、送信者アドレス、メールヘッダー、本文、および利用者が任意に添付した情報を受領します。これらは返信、サポート、報告の調査、不正利用の防止に使用し、その目的または法的・セキュリティ上の義務に合理的に必要な期間だけ保持します。これらの義務に反しない範囲で、同じ宛先へ削除を依頼できます。

## App Store privacy response / App Store申告

For data collected automatically by the app, the intended App Store privacy response is **Data Not Collected**. Voluntary support email is separate from the app's on-device processing and must also be considered when the response is reviewed before every release. Review again whenever telemetry, cloud sync, feedback upload, external AI, or an external-sensor cloud is added.

アプリが自動的に収集するデータについて、App Store申告予定は**「データを収集しない」**です。利用者が任意に送るサポートメールはアプリ内のオンデバイス処理とは別であり、各リリース前の申告確認時に併せて検討します。テレメトリー、クラウド同期、フィードバック送信、外部AI、外部センサーのクラウド連携を追加する場合も再確認します。

## Children / 子ども

Bameyasu is a general productivity tool and does not knowingly collect personal information through the app from anyone, including children.

Bameyasuは一般的な生産性向けツールであり、子どもを含む利用者からアプリを通じて個人情報を意図的に収集しません。

## Changes and contact / 変更・連絡先

Policy changes will be published in the repository and identified by the effective date. Send privacy inquiries and reports to [support@hinoshiba.com](mailto:support@hinoshiba.com). Do not include real sensor data, images, audio, or personal information unless the maintainer explicitly arranges a safer transfer method for that non-credential diagnostic material. Never send credentials or signing material; report only its type, path, and affected commit or job.

変更時はリポジトリで公開し、発効日を更新します。プライバシーに関する問い合わせ・報告は[support@hinoshiba.com](mailto:support@hinoshiba.com)へお送りください。管理者が資格情報ではない診断資料について安全な送付方法を明示した場合を除き、実際のセンサーデータ、画像、音声、個人情報を含めないでください。資格情報や署名資材は決して送らず、種類と影響したパス・コミット・ジョブだけを知らせてください。
