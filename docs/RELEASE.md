# Local Xcode release runbook

Official App Store builds are created on the maintainer's authorized Mac using local Xcode. PR CI only validates source and builds/tests an unsigned Simulator app. After the migration check below, release tags are source references and do not trigger uploads.

## One-time migration check

Before creating another release tag, check whether an old Xcode Cloud release workflow exists in Xcode or App Store Connect. If it does, deactivate it and confirm its automatic branch/tag starts and distribution actions are disabled. Removing repository hooks does not change these server-side settings. Preserve existing build history and artifacts; this repository change does not confirm the remote workflow has been stopped.

## Prepare the source

1. Update `main` with `git pull --ff-only` and work on a branch.
2. Use `Scripts/bump-version.sh` to update the marketing version and build number. Choose a build number above the latest upload in App Store Connect.
3. `project.yml` is the source of truth. Regenerate with XcodeGen 2.45.4 and commit the checked-in `Bameyasu.xcodeproj` with any configuration changes.
4. Run `./Scripts/check-release-readiness.sh`, `./build.sh`, and `./build.sh "iPhone 17 Pro" test` using an installed iPhone Simulator. Review permissions, the privacy policy, screenshots, measurement wording, and license notices.
5. Commit and push the branch, open a PR, and complete review before selecting the release commit.

## Archive and upload

1. Open `Bameyasu.xcodeproj` in local Xcode and select the `Bameyasu` scheme and a generic iOS device destination.
2. Verify the bundle identifier, version/build, and intended App Store Connect app. Follow the [code-signing policy](CODE_SIGNING.md). Signing uses the authorized local Keychain; credentials never belong in repository files or GitHub CI.
3. Choose **Product > Archive**. In Organizer, confirm the archived app identity and build, then choose **Distribute App > App Store Connect** to validate and upload.
4. Keep archives and export options outside the checkout. Verify processing and the exact build in App Store Connect, complete device testing and store metadata, then submit only the reviewed candidate.
5. Record the released commit, version/build, and Xcode version in the private release record. If a `vX.Y.Z` tag is used, create it on that reviewed commit and never replace or reuse it.

The app provides estimated workspace guidance; it must not be marketed as a medical device, calibrated instrument, or compliance meter.

Run `./Scripts/check-release-readiness.sh --history` separately when auditing the complete reachable Git history. Routine PR validation checks current source and tracked material, excluding ignored local build output.
