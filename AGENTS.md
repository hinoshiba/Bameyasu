# Repository Rules

## Code signing and secrets

- This is a public repository. Follow [the code-signing policy](docs/CODE_SIGNING.md) for every build, archive, release, and CI change.
- For apps owned by Apple Developer Team `94HVVWXLK3`, reuse an existing valid team-managed distribution signing identity when the certificate type and distribution channel match. Reuse means signing through an authorized macOS Keychain or managed signer; it never means copying the private key into a checkout.
- Team ID and certificate type can match more than one valid identity. Resolve the approved identity against the maintainer's private signing inventory or managed-signer alias outside the repository. Automatic signing and export can select or apply a cloud-managed identity, so neither a Keychain candidate nor the pre-export archive signature is proof of the final identity. Before upload, verify the distribution-signed exported product or Xcode Distribution Summary against the external inventory and stop on any mismatch. Do not choose an arbitrary first match or store that selector here.
- Do not create, revoke, rotate, import, export, or otherwise change signing identities without explicit maintainer authorization.
- Never read or export private-key material into the workspace. Never copy, encode, print, stage, commit, cache, or attach private keys, certificate/private-key bundles, provisioning profiles, App Store Connect API keys, or keychains. Keep signed release output outside the checkout and ordinary CI artifacts; send it only to an explicitly approved distribution destination under the signing policy.
- Listing identity metadata locally with `security find-identity -v -p codesigning` is allowed when needed, but do not paste or commit its output. Match candidates to the approved external inventory; never pin a certificate fingerprint in repository files.
- Keep ordinary local and CI simulator builds unsigned with `CODE_SIGNING_ALLOWED=NO`. Release signing must happen only on an authorized signer outside pull-request CI.
- `Developer ID Application` is for macOS distribution outside the Mac App Store. Do not configure it for this iOS target or treat it as a Mac App Store identity.
- If signing or credential material appears in the workspace, do not display its contents. Stop, report only the path and material type to the maintainer, and follow the incident procedure in the signing policy.
