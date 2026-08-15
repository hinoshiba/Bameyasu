# iOS Release Runbook

This follows the useful operating principles in [Youyaku](https://github.com/hinoshiba/youyaku): XcodeGen as the source of truth, explicit versioning, Privacy Manifest, complete notices, and a written App Store checklist. Bameyasu adds normal PR build/test and license/privacy gates.

## One-time App Store setup

1. Complete the legal clearance and reservation gate in `BRAND_AUDIT.md`.
2. Confirm that the canonical repository remains `hinoshiba/Bameyasu`, that
   `origin` points to it, and that every in-app source, issue, and security URL
   resolves before release.
3. Register `com.hinoshiba.bameyasu` and enable only required capabilities. A
   bundle identifier cannot be changed after the App Store record is created.
   The earlier `Akari` and `Habimetry` identifiers were pre-release working
   names and were never shipped, so no sandbox-data migration is provided. If
   any build has already been distributed outside this repository, stop and
   design an explicit migration before changing its identifier or storage path.
4. Set the primary category to Productivity. Avoid medical, diagnostic, safety-guarantee, and compliance claims.
5. Execute the Paid Apps Agreement and configure banking/tax details if sold.
6. Decide EU DSA trader status and provide the required verified contact details.
7. Host `PRIVACY.md`, support, and terms over HTTPS; replace the repository-only contact placeholder.
8. Configure App Store privacy as Data Not Collected only after comparing the submitted binary to `PRIVACY.md`.

## Version

```bash
./Scripts/bump-version.sh 0.1.0 1
```

The marketing version is three integers. The build number must monotonically increase in App Store Connect. Never replace a tagged release binary; issue a new build/version.

## Preflight

```bash
./Scripts/check-release-readiness.sh
xcodegen generate
xcodebuild \
  -project Bameyasu.xcodeproj \
  -scheme Bameyasu \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' \
  test CODE_SIGNING_ALLOWED=NO
```

Then manually verify on at least one supported physical iPhone:

- camera allowed, denied, and revoked;
- microphone allowed, denied, route changed, and interrupted;
- backgrounding/cancellation stops all sensors;
- no camera frame or audio file appears in the app container;
- airplane-mode full flow works;
- Japanese and English;
- light/dark mode, largest Dynamic Type, VoiceOver, Reduce Motion;
- empty, partial, and complete results;
- Privacy/Terms/Sources/Licenses are reachable in-app.

## Validation and claims

Do not publish numeric accuracy claims for camera lux or sound until the protocol in `METHODOLOGY.md` is completed and its evidence is public. Review screenshots, subtitle, keywords, description, and review notes for prohibited implications such as “medical device,” “diagnosis,” “safe,” “certified,” or “legal compliance.”

Suggested review note:

> Bameyasu is an on-device workspace wellness/education tool, not a medical device or calibrated/compliance instrument. Camera, microphone, and motion inputs are analyzed live only during user-started steps; images, video, audio, and raw sensor samples are not saved or transmitted. Camera illuminance and sound are explicitly labeled as estimates/reference values. The app has no account, ads, analytics SDK, or networking code. Permission denial does not block the remaining self-checks. Methodology and source links are available in the Guide tab.

## Store assets

- Name: `Bameyasu – 仕事環境チェック`
- English name: `Bameyasu – Workspace Check`
- Subtitle: `光・音・姿勢を60秒で見える化`
- First screenshot: `60秒で、まず直す1つがわかる`
- Subsequent messages: on-device analysis, immediate recheck, methodology transparency, no saved/transmitted image/audio.
- Do not use public-agency logos, third-party trademarks as keywords, SF Symbols in the app icon, or simulated hardware frames inconsistent with Apple's current requirements.

Use TestFlight internal testing, then external testing, App Review, and phased release. Ask for a rating only after a completed improvement/recheck, never during permissions or after a poor result.
