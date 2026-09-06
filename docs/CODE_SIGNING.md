# Code signing

Official App Store archives are prepared by the maintainer using local Xcode and an authorized Keychain.

- Apple Developer Team ID: `94HVVWXLK3`
- App bundle identifier: `com.hinoshiba.bameyasu`
- Local Simulator builds and GitHub PR CI use `CODE_SIGNING_ALLOWED=NO` and require no Apple account.

Open the checked-in project, verify the intended team and app record, and use the existing authorized App Store distribution identity for the archive. Keep all private keys, certificates, provisioning profiles, account credentials, export options, and signed archives outside the repository. Do not generate, export, import, rotate, or revoke signing identities as a routine build step.

`Developer ID Application` is for macOS software distributed outside the Mac App Store. It must not sign an App Store archive.

See [RELEASE.md](RELEASE.md) for the local archive and Organizer workflow. If confidential signing material is exposed, report its type, path, and affected commit privately to [support@hinoshiba.com](mailto:support@hinoshiba.com), without sending the material itself.
