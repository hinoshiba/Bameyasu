# Code-Signing and Secret-Handling Policy

This policy is normative for Bameyasu. The repository is public and contains only non-secret signing metadata.

## Team and application identity

- Apple Developer Team ID: `94HVVWXLK3`
- App bundle identifier: `com.hinoshiba.bameyasu`
- Unit-test bundle identifier: `com.hinoshiba.bameyasu.tests`
- Xcode signing mode: automatic

Team IDs, bundle identifiers, and certificate class names are public configuration. Private keys, credentials, and exported signing identities are not.

## Reuse the team-managed identity

For applications owned by the same Developer Team, reuse an existing valid team-managed distribution identity when its certificate type and distribution channel match. Do not create or export an app-specific copy merely because the application lives in another repository.

“Reuse” means that an authorized build Mac signs through the identity already held in its macOS Keychain, or that an approved managed signer supplies the identity at signing time. It does not mean copying a `.p12`, private key, profile, or Keychain database between repositories or placing one anywhere in a checkout.

Team ID and certificate type narrow the candidates but do not uniquely select an identity: Apple can issue multiple valid identities of the same class. The maintainer must keep the canonical fingerprint or managed-signer alias in an approved private signing inventory outside the repository. Automatic signing can use a cloud-managed certificate, and Xcode can apply distribution signing during export, so limiting the local Keychain and checking only the pre-export archive do not prove the final identity.

Before upload, the authorized release process must inspect the distribution-signed exported app, IPA, or package—or Xcode's Distribution Summary—in a temporary location outside the checkout and compare its leaf signing certificate with the external inventory. Stop on any mismatch. When policy requires the existing shared identity and automatic signing cannot guarantee it, use a separately reviewed external manual-signing workflow; do not let Xcode create or substitute another identity implicitly.

Do not pin a certificate SHA fingerprint, managed alias, or owner string anywhere in the repository. Certificates expire, rotate, and can be revoked; update the private inventory when the approved identity changes.

## Match the certificate to the distribution channel

Bameyasu currently has an iPhone-only iOS target. It uses Xcode automatic signing for device and App Store work, while routine simulator builds disable signing.

- iOS device development: use the Apple Development identity and development profile selected for Team `94HVVWXLK3` by Xcode automatic signing.
- iOS TestFlight or App Store: use the Apple Distribution identity and App Store Connect provisioning profile selected by Xcode automatic signing.
- Mac App Store, if a Mac target is added later: use the current App Store-appropriate Mac distribution identity and profile selected by Xcode, and enable App Sandbox. A Mac installer package requires the corresponding Mac installer distribution identity.
- macOS distribution outside the Mac App Store: use `Developer ID Application`; use `Developer ID Installer` for an installer package, enable Hardened Runtime, and follow Apple's notarization requirements.

`Developer ID Application` is for macOS software distributed outside the Mac App Store. It must not be configured for the current iOS target or described as a Mac App Store certificate.

Apple documents these certificate purposes in its [certificates overview](https://developer.apple.com/help/account/certificates/certificates-overview) and [Developer ID certificate guide](https://developer.apple.com/help/account/certificates/create-developer-id-certificates/). Platform protections are covered by Apple's [distribution preparation](https://developer.apple.com/documentation/xcode/preparing-your-app-for-distribution) and [App Sandbox](https://developer.apple.com/documentation/security/app-sandbox) documentation.

## Repository boundary

Never place any of the following in the repository, a worktree subdirectory, Git history, an issue, a pull request, a log, a cache, or an ordinary CI artifact:

- private keys or exported identities, including `.p12`, `.pfx`, `.pkcs12`, `.p8`, `.pem`, and `.key` files;
- signing certificates or certificate requests, including `.cer`, `.crt`, `.der`, `.certSigningRequest`, and `.csr` files;
- provisioning profiles, including `.mobileprovision` and `.provisionprofile` files;
- App Store Connect API keys, authentication-key files, `.env` files, passwords, tokens, or credential JSON;
- macOS Keychain databases, Java keystores, signed `.ipa` files, signed Mac installers, disk images, or `.xcarchive` directories.

Do not create a `Signing`, `SigningAssets`, `Certificates`, `ProvisioningProfiles`, `Secrets`, or similar material-holding directory inside the checkout. `.gitignore` is a guardrail, not an approved storage mechanism.

Signed release output is not a private key, but it still stays outside the checkout. An authorized release may submit it to App Store Connect, TestFlight, Apple's notarization service, or another explicitly approved distribution destination. This exception never permits credentials or private-key material in the submission bundle, repository, logs, caches, or CI artifacts.

Allowed repository content is limited to non-secret metadata, policy, and unsigned build configuration. The certificate fingerprint shown by `security find-identity` is operational output: keep it local and do not pin or commit it.

Keep every `ExportOptions*.plist` outside this public repository. Although an export-options file can contain non-secret build configuration, it can also pin signing certificates, provisioning profiles, or release destinations. A future checked-in export configuration requires a separate security review and an explicit policy change.

## Local and CI builds

Normal development and pull-request CI use an iOS Simulator and `CODE_SIGNING_ALLOWED=NO`. They do not need access to a signing identity.

An authorized maintainer may verify local identity metadata without exporting it:

```sh
security find-identity -v -p codesigning
```

Do not redirect, paste, or upload that command's output. Do not run `security export`, base64 encoding, or similar extraction on signing or credential material from inside this repository.

If signed CI is introduced later, it must be isolated from untrusted pull requests, use a protected environment or approved managed signing service, load credentials only at runtime, prevent secret output, and destroy any temporary Keychain before the job ends. That design requires a separate security review and explicit maintainer approval.

## Exposure response

If signing or credential material is added or disclosed, removing the file in a later commit is not sufficient. Do not resend or display the material. Report only its type, path, and affected commit or job to [support@hinoshiba.com](mailto:support@hinoshiba.com), then:

1. revoke or rotate the affected certificate, private key, API key, token, or profile as appropriate;
2. remove the material from reachable Git history and invalidate affected caches and artifacts;
3. assume existing clones and forks may retain the disclosed value;
4. document the incident without reproducing the secret; and
5. restore signing only after a new authorized identity is installed outside the repository.
