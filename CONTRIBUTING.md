# Contributing

Thank you for improving Bameyasu.

1. Search existing issues before opening one.
2. Discuss major features, new sensors, thresholds, dependencies, permissions, networking, or health wording in an issue first.
3. Keep a pull request focused on one change.
4. Run XcodeGen, build, tests, and `Scripts/check-release-readiness.sh`.
5. Update user documentation, methodology, evidence, privacy, algorithm version, and third-party notices whenever applicable.
6. Never add a measurement that the public iOS API cannot actually provide, or convert dBFS into dBA/lux without documenting and validating the method.
7. Follow the [code-signing policy](docs/CODE_SIGNING.md). Apps in the same Developer Team reuse an authorized team-managed distribution identity through the local Keychain or an approved signer; never copy that identity into a checkout.
8. Do not commit or attach to repository collaboration channels any secret, private key, certificate/private-key bundle, signing certificate, provisioning profile, App Store Connect API key, Keychain, signed release archive, captured camera/audio data, or personal information. Do not send signing material through an issue, pull request, email, or alternate transfer channel; approved release-output submission is handled separately under the signing policy.

By contributing, you agree that your contribution is licensed under the repository's MIT License and that you have the right to submit it. The project name and brand assets are governed separately by `TRADEMARKS.md`.
