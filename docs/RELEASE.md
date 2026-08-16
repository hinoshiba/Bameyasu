# Xcode Cloud Release Runbook

BameyasuのApp Store向けbinaryはXcode Cloudだけで作成します。通常のpull request CIは署名なしのSimulator buildを継続し、ローカルMacでのarchive、export、uploadはrelease手順に含めません。

## Release identity

- Xcode project: `Bameyasu.xcodeproj`
- Shared scheme: `Bameyasu`
- Platform: iOS (iPhone only)
- App bundle ID: `com.hinoshiba.bameyasu`
- Test bundle ID: `com.hinoshiba.bameyasu.tests`
- Apple Developer Team: `94HVVWXLK3`
- Version source: `MARKETING_VERSION` in `project.yml`
- Release tag: `vX.Y.Z` (for example, `v0.1.1`)

`project.yml` is the project-configuration source of truth, while the generated Xcode project is intentionally committed because Xcode Cloud requires a continuously present project or workspace. Whenever `project.yml` changes, run `xcodegen generate` and commit both files. Pull-request CI rejects a stale generated project.

## One-time Xcode Cloud setup

Complete the initial onboarding in Xcode after this change is merged to `main`:

1. Check out `main`, open `Bameyasu.xcodeproj`, select the `Bameyasu` scheme, and use Product > Xcode Cloud > Create Workflow (or the Cloud section of the Report navigator).
2. Select Team `94HVVWXLK3` and confirm the existing App Store Connect record whose bundle ID is exactly `com.hinoshiba.bameyasu`. Do not create a second app record or change the bundle ID.
3. Grant Xcode Cloud access to `hinoshiba/Bameyasu` through the GitHub authorization flow. Grant only the repository access needed for this product.
4. Allow Xcode to manage signing. Xcode Cloud uses Apple's managed signing service; no certificate, private key, provisioning profile, or App Store Connect key belongs in GitHub.
5. Start the initial validation build from `main`. This non-archive build is allowed by `ci_pre_xcodebuild.sh` and establishes the Xcode Cloud product.

After the first build, create or edit the release workflow in Xcode or App Store Connect with these settings:

| Section | Setting |
| --- | --- |
| General | Name: `App Store Release`; enable **Restrict Editing** |
| Start Conditions | **Tag Changes**; custom tag pattern `v*`; remove branch-change conditions; set **Auto-cancel Builds** to **Off** in this condition's Options |
| Environment | Latest stable Xcode and macOS supported by the project; **Clean** enabled |
| Action 1 | **Test**, scheme `Bameyasu`, latest supported iOS Simulator on an iPhone |
| Action 2 | **Archive**, platform **iOS**, scheme `Bameyasu`, Deployment Preparation **TestFlight and App Store** |
| Post-Actions | None required to upload the archive. Add a TestFlight post-action only when a specific tester group should receive every tagged build. |

The custom pre-Xcodebuild script rejects an Archive unless its platform, scheme, bundle ID, and Team match this product, `CI_TAG` is exactly `vX.Y.Z`, the tag version matches both `project.yml` and the checked-in project, and `CI_BUILD_NUMBER` is a positive integer. It then applies `CI_BUILD_NUMBER` as `CURRENT_PROJECT_VERSION` in the temporary checkout.

In App Store Connect, open Xcode Cloud > Settings > Build Number and set **Next Build Number** above the highest build already uploaded for the current version. The repository currently records build `1`, so use at least `2` unless App Store Connect already contains a higher build.

## Protect release authority

Before enabling the release workflow, create an **Active** tag ruleset in
GitHub **Settings > Rules > Rulesets** for the `v*` target pattern. Enable
**Restrict creations**, **Restrict updates**, and **Restrict deletions**, and
allow bypass only for the designated release manager. Create a release tag only
on a reviewed `main` commit. Never move, replace, or reuse it. Keep Xcode Cloud
**Restrict Editing** enabled and limit workflow administration to the same
small release group.

## Prepare and tag a release

1. Update the marketing version and local fallback build number:

   ```sh
   ./Scripts/bump-version.sh 0.1.1 2
   xcodegen generate
   ```

2. Run the repository checks and unsigned tests:

   ```sh
   ./Scripts/check-release-readiness.sh
   ./build.sh "iPhone 17 Pro" test
   ```

3. Verify on a supported physical iPhone: camera/microphone/motion permission allow and deny paths, sensor shutdown on cancellation/backgrounding, Japanese and English, airplane mode, light/dark mode, largest Dynamic Type, VoiceOver, and Reduce Motion.
4. Merge the version change through a reviewed pull request. Wait for GitHub CI on the merge commit to pass.
5. Create the tag on that exact `main` commit and push it:

   ```sh
   git tag -a v0.1.1 -m "Bameyasu 0.1.1"
   git push origin v0.1.1
   ```

Never move or replace a release tag. Correct a failed or superseded release with a new version tag.

## Verify the cloud release

1. In App Store Connect > Bameyasu > Xcode Cloud, confirm that `App Store Release` was started by the expected tag and commit.
2. Require successful Test and Archive actions. Confirm the Archive report resolves Team `94HVVWXLK3`, bundle ID `com.hinoshiba.bameyasu`, the tag's marketing version, and the Xcode Cloud build number.
3. Wait for App Store Connect processing. Confirm the exact version/build appears in TestFlight and is eligible for App Store submission.
4. Review the submitted binary against `PRIVACY.md`, the Privacy Manifest, permissions, screenshots, product copy, and review notes. Bameyasu must not be described as a medical device, calibrated instrument, or compliance meter.
5. Selecting the build for an App Store version and submitting it to App Review remain explicit App Store Connect actions. A release tag uploads a candidate; it does not submit or release the app automatically.

Follow the repository [code-signing policy](CODE_SIGNING.md). Keep signed artifacts in Xcode Cloud/App Store Connect, not in the checkout or ordinary GitHub Actions artifacts.
