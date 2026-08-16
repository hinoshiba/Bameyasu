# iOS Release Runbook

This follows the useful operating principles in [Youyaku](https://github.com/hinoshiba/youyaku): XcodeGen as the source of truth, explicit versioning, Privacy Manifest, complete notices, and a written App Store checklist. Bameyasu adds normal PR build/test and license/privacy gates.

## One-time App Store setup

1. Complete the legal clearance and reservation gate in `BRAND_AUDIT.md`.
2. Confirm that the canonical repository remains `hinoshiba/Bameyasu`, that
   `origin` points to it, and that every in-app source, issue, and security URL
   resolves before release.
3. Register `com.hinoshiba.bameyasu` and enable only required capabilities. A
   bundle identifier cannot be changed after the App Store record is created.
   Changing from any previous pre-release identifier creates a new sandbox
   identity, and this repository does not provide automatic data migration. If
   any build has already been distributed outside this repository, stop and
   design an explicit migration before changing its identifier or storage path.
4. Set the primary category to Productivity. Avoid medical, diagnostic, safety-guarantee, and compliance claims.
5. Execute the Paid Apps Agreement and configure banking/tax details if sold.
6. Decide EU DSA trader status and provide the required verified contact details.
7. Confirm that the HTTPS privacy, support, and terms pages resolve and that `support@hinoshiba.com` is monitored.
8. Configure App Store privacy as Data Not Collected only after comparing the submitted binary to `PRIVACY.md`.

## Code signing and secret boundary

Follow the repository's [code-signing policy](CODE_SIGNING.md). For Team `94HVVWXLK3`, reuse the existing valid team-managed distribution identity when its certificate type matches the distribution channel. Reuse it through an authorized macOS Keychain or approved managed signer; never copy or export its private key into this repository or create a per-app copy as routine practice.

Team ID and certificate type are not a unique selector when multiple valid identities exist. Keep the canonical fingerprint or managed alias in the maintainer's approved private signing inventory outside this repository. Automatic signing can select a cloud-managed identity and export can apply distribution signing, so neither the local Keychain list nor the pre-export archive is sufficient proof. Before upload, inspect the distribution-signed exported product or Xcode Distribution Summary outside the checkout, compare its leaf signing certificate to the external inventory, and stop on any mismatch. If the approved shared identity cannot be guaranteed automatically, use a separately reviewed external manual-signing workflow. Never record the private selector in project files.

This project is currently iOS-only and keeps `CODE_SIGN_STYLE: Automatic`. Xcode selects an Apple Development identity and development profile for physical-device development, and an Apple Distribution identity with an App Store Connect provisioning profile for TestFlight and App Store submission. `Developer ID Application` is reserved for macOS distribution outside the Mac App Store and must not be assigned to this target. A future Mac App Store target must use the App Store-appropriate Mac identity and profile and enable App Sandbox instead.

The repository may record Team ID, bundle identifiers, and certificate class names. It must never contain a private key, exported identity, certificate bundle, provisioning profile, App Store Connect API key, Keychain, signed archive, or certificate fingerprint. Routine simulator and pull-request builds remain unsigned with `CODE_SIGNING_ALLOWED=NO`.

Before a signed release, an authorized maintainer may list local identity metadata with `security find-identity -v -p codesigning`. Do not commit or upload the output, and do not export the identity from inside the checkout. Identity creation, import, export, renewal, revocation, or CI secret provisioning requires explicit maintainer authorization.

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
