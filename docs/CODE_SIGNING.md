# Code-Signing and Secret-Handling Policy

This policy is normative for Bameyasu. The public repository contains only non-secret signing metadata.

## Public application identity

- Apple Developer Team ID: `94HVVWXLK3`
- App bundle identifier: `com.hinoshiba.bameyasu`
- Unit-test bundle identifier: `com.hinoshiba.bameyasu.tests`
- Signing mode: automatic
- App Store release builder: Xcode Cloud

Team IDs, bundle identifiers, and certificate class names are public configuration. Private keys, credentials, exported identities, managed-signer selectors, and provisioning profiles are not.

## Build boundaries

Routine local development and GitHub pull-request CI use an iOS Simulator with `CODE_SIGNING_ALLOWED=NO`. They must not archive, import signing material, or upload a binary.

App Store archives run only in the restricted `App Store Release` Xcode Cloud workflow described in [RELEASE.md](RELEASE.md). Xcode Cloud must resolve the existing App Store Connect app for `com.hinoshiba.bameyasu`, Team `94HVVWXLK3`, automatic signing, and Apple's managed distribution path. The initial setup owner must verify the exact team, app record, and repository before granting access. After each archive, verify those same values in the Xcode Cloud build report and App Store Connect delivery record.

Do not add signing identities, provisioning-profile selectors, certificate fingerprints, or credentials to the project, workflow environment, custom scripts, or repository. Do not create, revoke, rotate, import, or export a team signing identity as a speculative fix. If Xcode Cloud cannot resolve managed signing for the exact app and team, stop and diagnose the account, App ID, capability, and role configuration.

`Developer ID Application` is for macOS software distributed outside the Mac App Store. It must not be configured for this iOS target.

## Repository boundary

Never place any of the following in the repository, Git history, an issue, a pull request, a log, a cache, or an ordinary CI artifact:

- private keys or exported identities, including `.p12`, `.pfx`, `.pkcs12`, `.p8`, `.pem`, and `.key` files;
- signing certificates or certificate requests, including `.cer`, `.crt`, `.der`, `.certSigningRequest`, and `.csr` files;
- provisioning profiles, including `.mobileprovision` and `.provisionprofile` files;
- App Store Connect API keys, authentication-key files, `.env` files, passwords, tokens, credential JSON, or Keychain databases;
- signed `.ipa` files, packages, disk images, or `.xcarchive` directories; or
- private certificate fingerprints, identity output, or managed-signer aliases.

Keep `ExportOptions*.plist` outside this public repository. Xcode Cloud's managed workflow does not require a checked-in export-options file.

Signed release output remains in Xcode Cloud and App Store Connect. Download an artifact only into an approved temporary location when investigation or archival is required; never commit or attach it to routine GitHub CI.

## Exposure response

If signing or credential material is disclosed, do not display or resend it. Report only its material type, path, and affected commit or job to [support@hinoshiba.com](mailto:support@hinoshiba.com), then:

1. revoke or rotate the affected credential or signing object as appropriate;
2. remove it from reachable history and invalidate affected caches and artifacts;
3. assume existing clones and forks may retain it;
4. document the incident without reproducing the secret; and
5. restore cloud signing only after the exact app, team, repository access, and replacement credential state are verified.
