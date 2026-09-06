# Contributing

Thank you for improving Bameyasu.

1. Search existing issues before opening one.
2. Discuss major features, new sensors, thresholds, dependencies, permissions, networking, or health wording in an issue first.
3. Keep a pull request focused on one change.
4. Run XcodeGen, build, tests, and `Scripts/check-release-readiness.sh`.
5. Update user documentation, methodology, evidence, privacy, algorithm version, and third-party notices whenever applicable.
6. Never add a measurement that the public iOS API cannot actually provide, or convert dBFS into dBA/lux without documenting and validating the method.
7. Follow the [code-signing policy](docs/CODE_SIGNING.md). Official archives are prepared in local Xcode by the release maintainer; routine builds and PR CI require no Apple account or distribution identity.
8. Do not commit or attach to repository collaboration channels any secret, private key, certificate/private-key bundle, signing certificate, provisioning profile, App Store Connect API key, Keychain, signed release archive, captured camera/audio data, or personal information. Do not send signing material through an issue, pull request, email, or alternate transfer channel; Signing material stays in the authorized local Keychain; see the local release runbook.

By contributing, you agree that your contribution is licensed under the repository's MIT License and that you have the right to submit it. The project name and brand assets are governed separately by `TRADEMARKS.md`.

## Submitting changes

Start from an updated `main` (`git checkout main && git pull --ff-only`) and create a focused branch. After making changes, run the relevant checks, review the diff, then `git commit` and `git push` your branch before opening a pull request with the shared template. Use an email address you intend to publish in commit metadata. Maintainer-authored commits use `support@hinoshiba.com`.

The website is a single Japanese/English page with an in-place language switch. Keep section anchors and old URL redirects working; verify narrow, tablet, and desktop widths when changing its layout.
