#!/bin/sh
set -eu

/bin/sh -n ci_scripts/*.sh

required_files='LICENSE
PRIVACY.md
TERMS.md
METHODOLOGY.md
SOURCES.md
THIRD_PARTY_NOTICES.txt
SECURITY.md
CONTRIBUTING.md
CODE_OF_CONDUCT.md
TRADEMARKS.md
docs/BRAND_AUDIT.md
docs/CODE_SIGNING.md
Bameyasu.xcodeproj/project.pbxproj
Bameyasu.xcodeproj/xcshareddata/xcschemes/Bameyasu.xcscheme
ci_scripts/ci_pre_xcodebuild.sh
Bameyasu/Resources/PrivacyInfo.xcprivacy
Bameyasu/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png'

echo "$required_files" | while IFS= read -r file; do
  if [ ! -s "$file" ]; then
    echo "error: required release file is missing or empty: $file" >&2
    exit 1
  fi
done

plutil -lint Bameyasu/Resources/PrivacyInfo.xcprivacy >/dev/null
plutil -lint Bameyasu/Resources/Info.plist >/dev/null

forbidden_material_path='(^|/)(signing|signingassets|certificates|provisioningprofiles|secrets?)/|(^|/)(AuthKey_[^/]+\.p8|ExportOptions[^/]*\.plist|credentials?(\.[^/]*)?\.json|api[_-]?key(\.[^/]*)?\.json|app[_-]?store[_-]?connect[^/]*\.json|[^/]+\.(p12|pfx|pkcs12|p8|pem|key|cer|crt|der|certSigningRequest|csr|mobileprovision|provisionprofile|keychain|keychain-db|jks|keystore|ipa|pkg|dmg))$|\.xcarchive/'

if git ls-files | rg -ni "$forbidden_material_path"; then
  echo "error: signing, credential, or signed release material is tracked" >&2
  exit 1
fi

if git ls-files | rg -ni '(^|/)\.env($|\.)'; then
  echo "error: environment credential file is tracked" >&2
  exit 1
fi

if rg --files --hidden --no-ignore --glob '!.git/**' | rg -ni "$forbidden_material_path"; then
  echo "error: signing, credential, or signed release material exists inside the checkout" >&2
  exit 1
fi

if rg --files --hidden --no-ignore --glob '!.git/**' \
  | rg -ni '(^|/)\.env($|\.)'; then
  echo "error: environment credential file exists inside the checkout" >&2
  exit 1
fi

private_key_marker=$(printf '%s%s' 'PRIVATE ' 'KEY-----')
if rg -lF --hidden --no-ignore --glob '!.git/**' "$private_key_marker" .; then
  echo "error: private-key material exists inside the checkout" >&2
  exit 1
fi

if git grep -IlF "$private_key_marker" -- .; then
  echo "error: private-key material found in tracked content" >&2
  exit 1
fi

credential_assignment_pattern="(?i)(?<![A-Za-z0-9_-])['\"]?(?:api[_-]?(?:key|token)|access[_-]?token|auth[_-]?token|client[_-]?secret|aws[_-]?secret[_-]?access[_-]?key|secret[_-]?access[_-]?key)['\"]?\\s*[:=]\\s*['\"]?(?=[A-Za-z0-9_./+=-]{20,}(?:['\",}\\s]|$))(?=[A-Za-z0-9_./+=-]*[0-9])(?=[A-Za-z0-9_./+=-]*[A-Za-z])[A-Za-z0-9_./+=-]{20,}"
if rg -lP --hidden --no-ignore --glob '!.git/**' "$credential_assignment_pattern" .; then
  echo "error: credential-like assignment exists inside the checkout" >&2
  exit 1
fi

private_key_assignment_pattern="(^|[^[:alnum:]_-])['\"]?private[_-]?key['\"]?[[:space:]]*[:=][[:space:]]*['\"]?[[:alnum:]/+=]{24,}"
if rg -li --hidden --no-ignore --glob '!.git/**' "$private_key_assignment_pattern" .; then
  echo "error: private-key assignment exists inside the checkout" >&2
  exit 1
fi

if git grep -IlEi "$private_key_assignment_pattern" -- .; then
  echo "error: private-key assignment is tracked" >&2
  exit 1
fi

authorization_value_pattern=$(printf '%s%s' "['\"]?Author" "ization['\"]?[[:space:]]*:[[:space:]]*['\"]?(Bearer|Basic)[[:space:]]+[[:alnum:]._~+/-]{16,}")
credential_value_pattern="github_pat_[[:alnum:]_]{20,}|gh[pousr]_[[:alnum:]]{20,}|(AKIA|ASIA)[[:upper:][:digit:]]{16}|$authorization_value_pattern"
if rg -li --hidden --no-ignore --glob '!.git/**' "$credential_value_pattern" .; then
  echo "error: credential-like value exists inside the checkout" >&2
  exit 1
fi

if git grep -IlEi "$credential_value_pattern" -- .; then
  echo "error: credential-like value found in tracked content" >&2
  exit 1
fi

identity_output_pattern='^[[:space:]]*[0-9]+\) [[:xdigit:]]{40} ".*(Developer ID|Distribution|Development)'
if rg -l --hidden --no-ignore --glob '!.git/**' "$identity_output_pattern" .; then
  echo "error: signing identity output exists inside the checkout" >&2
  exit 1
fi

if git grep -IlE "$identity_output_pattern" -- .; then
  echo "error: signing identity output or certificate fingerprint is tracked" >&2
  exit 1
fi

selector_key_pattern='cert(ificate)?[_-]?(fingerprint|sha1|sha256|owner|alias)|signing[_-]?(fingerprint|identity|owner|alias)|managed[_-]?signer[_-]?alias|PROVISIONING_PROFILE(_SPECIFIER)?'
private_selector_pattern="(^|[^[:alnum:]_-])['\"]?($selector_key_pattern)['\"]?(\[[^]]+\])?[[:space:]]*=[[:space:]]*['\"]?[^[:space:]'\",}]{4,}|^[[:space:]]*['\"]?($selector_key_pattern)['\"]?(\[[^]]+\])?[[:space:]]*:[[:space:]]*['\"][^'\"]{4,}"
if rg -li --hidden --no-ignore \
  --glob '!.git/**' \
  --glob '!DerivedData/**' \
  --glob '!build/**' \
  --glob '!*.xcodeproj/**' \
  "$private_selector_pattern" .; then
  echo "error: private signing selector assignment exists inside the checkout" >&2
  exit 1
fi

if git grep -IlEi "$private_selector_pattern" -- .; then
  echo "error: private signing selector assignment is tracked" >&2
  exit 1
fi

if [ "$(git rev-parse --is-shallow-repository)" = "true" ]; then
  echo "error: full Git history is required for secret-material checks" >&2
  exit 1
fi

if git log --all --name-only --format= | rg -ni "$forbidden_material_path"; then
  echo "error: signing, credential, or signed release material exists in reachable history" >&2
  exit 1
fi

if git log --all --name-only --format= | rg -ni '(^|/)\.env($|\.)'; then
  echo "error: environment credential file exists in reachable history" >&2
  exit 1
fi

for commit in $(git rev-list --all); do
  if git grep -IlF "$private_key_marker" "$commit" -- .; then
    echo "error: private-key material exists in reachable history at commit $commit" >&2
    exit 1
  fi
  if git grep -IlP "$credential_assignment_pattern" "$commit" -- .; then
    echo "error: credential-like assignment exists in reachable history at commit $commit" >&2
    exit 1
  fi
  if git grep -IlEi "$credential_value_pattern" "$commit" -- .; then
    echo "error: credential-like value exists in reachable history at commit $commit" >&2
    exit 1
  fi
  if git grep -IlEi "$private_key_assignment_pattern" "$commit" -- .; then
    echo "error: private-key assignment exists in reachable history at commit $commit" >&2
    exit 1
  fi
  if git grep -IlE "$identity_output_pattern" "$commit" -- .; then
    echo "error: signing identity output exists in reachable history at commit $commit" >&2
    exit 1
  fi
  if git grep -IlEi "$private_selector_pattern" "$commit" -- .; then
    echo "error: private signing selector assignment exists in reachable history at commit $commit" >&2
    exit 1
  fi
  unexpected_historical_signing_identities=$(git grep -IhE \
    '^[[:space:]]*CODE_SIGN_IDENTITY(\[[^]]+\])?[[:space:]]*[:=]' \
    "$commit" -- . 2>/dev/null \
    | rg -v '^[[:space:]]*CODE_SIGN_IDENTITY = "iPhone Developer";$' || true)
  if [ -n "$unexpected_historical_signing_identities" ]; then
    echo "error: non-generic signing identity exists in reachable history at commit $commit" >&2
    exit 1
  fi
done

if rg -n '^[[:space:]]*PROVISIONING_PROFILE(_SPECIFIER)?(\[[^]]+\])?[[:space:]]*[:=]' \
    project.yml Bameyasu.xcodeproj --glob 'project.yml' --glob '*.xcconfig' --glob '*.pbxproj'; then
  echo "error: provisioning profiles must not be pinned in project configuration" >&2
  exit 1
fi

unexpected_signing_identities=$(rg -n \
  '^[[:space:]]*CODE_SIGN_IDENTITY(\[[^]]+\])?[[:space:]]*[:=]' \
  project.yml Bameyasu.xcodeproj --glob 'project.yml' --glob '*.xcconfig' --glob '*.pbxproj' \
  | rg -v 'CODE_SIGN_IDENTITY = "iPhone Developer";$' || true)
if [ -n "$unexpected_signing_identities" ]; then
  echo "$unexpected_signing_identities" >&2
  echo "error: only XcodeGen's generic iPhone Developer selector is allowed with automatic signing" >&2
  exit 1
fi

if rg -n 'contact-placeholder|CHANGEME|YOUR_EMAIL|TODO: release|Until a public support address is configured|公開サポート窓口の設定前|confidential reporting channel is being prepared|非公開の報告窓口は準備中|private vulnerability reporting' \
  PRIVACY.md TERMS.md SECURITY.md README.md CODE_OF_CONDUCT.md docs Bameyasu site .github; then
  echo "error: release placeholder found" >&2
  exit 1
fi

support_contact_files='PRIVACY.md
SECURITY.md
README.md
CODE_OF_CONDUCT.md
Bameyasu/Views/SettingsView.swift
site/index.html
site/en/index.html
.github/ISSUE_TEMPLATE/config.yml
.github/ISSUE_TEMPLATE/bug_report.yml'

echo "$support_contact_files" | while IFS= read -r file; do
  if ! grep -q 'support@hinoshiba\.com' "$file"; then
    echo "error: canonical support contact is missing from: $file" >&2
    exit 1
  fi
done

if rg -n 'dBA 推定|音声は録音されません|Audio is never recorded' Bameyasu; then
  echo "error: misleading sensor wording found" >&2
  exit 1
fi

if rg -n 'Habimetry|habimetry|ハビメトリー|com\.hinoshiba\.akari|hinoshiba/Akari' \
  Bameyasu BameyasuTests project.yml README.md PRIVACY.md TERMS.md \
  METHODOLOGY.md SOURCES.md TRADEMARKS.md .github build.sh \
  --glob '!BRAND_AUDIT.md'; then
  echo "error: retired product name or identifier found outside the audit record" >&2
  exit 1
fi

noncanonical_bundle_id=$(printf '%s%s' 'bameyasu.hinoshiba.' 'com')
if rg -nF "$noncanonical_bundle_id" \
  project.yml Bameyasu/Services/LightMeter.swift Bameyasu/Services/MotionMeter.swift; then
  echo "error: noncanonical Bameyasu identifier found" >&2
  exit 1
fi

if git grep -IioE 'com\.hinoshiba\.bameyasu' -- . \
  | cut -d: -f2- \
  | grep -Fvx 'com.hinoshiba.bameyasu'; then
  echo "error: Bameyasu identifier must be lowercase" >&2
  exit 1
fi

configured_bundle_ids=$(sed -n 's/^[[:space:]]*PRODUCT_BUNDLE_IDENTIFIER: //p' project.yml)
expected_bundle_ids='com.hinoshiba.bameyasu
com.hinoshiba.bameyasu.tests'

if [ "$configured_bundle_ids" != "$expected_bundle_ids" ]; then
  echo "error: unexpected product bundle identifier in project.yml" >&2
  exit 1
fi

grep -Fqx 'name: Bameyasu' project.yml
grep -Fqx '  bundleIdPrefix: com.hinoshiba' project.yml
grep -Fqx '    CODE_SIGN_STYLE: Automatic' project.yml
grep -Fqx '    DEVELOPMENT_TEAM: "94HVVWXLK3"' project.yml
automation_file_pattern='^Scripts/|^project\.yml$|^Package\.swift$|^\.github/workflows/.*\.ya?ml$|^\.github/actions/(.*/)?action\.ya?ml$|(^|/)([^/]+\.(sh|bash|zsh|rb|py|pl|js|mjs|cjs|ts)|Makefile|GNUmakefile|Fastfile|Rakefile|Justfile|Podfile|Cartfile|package\.json|project\.pbxproj|Taskfile(\.ya?ml)?)$'
tracked_executable_files=$(git ls-files --stage | awk '$1 == "100755"' | cut -f2-)
automation_files=$(
  {
    rg --files --hidden --no-ignore \
      --glob '!.git/**' \
      --glob '!DerivedData/**' \
      --glob '!build/**' \
      --glob '!.build/**' \
      --glob '!*.xcodeproj/**' \
      | rg -i "$automation_file_pattern"
    printf '%s\n' "$tracked_executable_files"
  } \
    | sed '/^$/d' \
    | sort -u
)
if printf '%s\n' "$automation_files" | rg -n '[^[:alnum:]_./-]'; then
  echo "error: automation path contains whitespace or shell metacharacters and cannot be audited safely" >&2
  exit 1
fi
file_has_xcodebuild() {
  awk '
    /^[[:space:]]*#/ { next }
    { if (tolower($0) ~ /(^|[^[:alnum:]_])xcodebuild([^[:alnum:]_]|$)/) found = 1 }
    END { exit found ? 0 : 1 }
  ' "$1"
}
xcodebuild_files=''
for file in $automation_files; do
  if [ "$file" != 'Scripts/check-release-readiness.sh' ] \
    && file_has_xcodebuild "$file"; then
    if [ -n "$xcodebuild_files" ]; then
      xcodebuild_files="$xcodebuild_files
$file"
    else
      xcodebuild_files=$file
    fi
  fi
done
xcodebuild_files=$(printf '%s\n' "$xcodebuild_files" | sed '/^$/d' | sort)
allowed_xcodebuild_files='.github/workflows/ci.yml
build.sh'
if [ "$xcodebuild_files" != "$allowed_xcodebuild_files" ]; then
  echo "error: xcodebuild invocation found outside the reviewed unsigned build entrypoints" >&2
  if [ -n "$xcodebuild_files" ]; then
    echo "$xcodebuild_files" >&2
  fi
  exit 1
fi
check_unsigned_xcodebuilds() {
  awk '
    function finish_command() {
      if (in_command && !unsigned) failed = 1
      in_command = 0
      unsigned = 0
    }
    {
      code = $0
      if (code ~ /^[[:space:]]*#/ || code ~ /^[[:space:]]*$/) {
        if (in_command) failed = 1
        next
      }
      lower = tolower(code)
      remaining = lower
      commands = 0
      while (match(remaining, /(^|[^[:alnum:]_])xcodebuild([^[:alnum:]_]|$)/)) {
        commands += 1
        remaining = substr(remaining, RSTART + RLENGTH)
      }
      if (commands > 1 || (in_command && commands > 0)) failed = 1
      if ((in_command || commands == 1) && code ~ /#/) failed = 1
      if (in_command && code ~ /(&&|\|\||;)/) failed = 1
      if (!in_command && commands == 1) {
        in_command = 1
        seen += 1
        if (lower ~ /(^|[^[:alnum:]_])archive([^[:alnum:]_]|$)/) failed = 1
        if (code ~ /(^|[[:space:]\\])CODE_SIGNING_ALLOWED=NO([^[:alnum:]_]|$)/) unsigned = 1
        if (code ~ /(&&|\|\||;)/) failed = 1
        if (code !~ /\\[[:space:]]*$/) finish_command()
        next
      }
      if (in_command) {
        if (lower ~ /(^|[^[:alnum:]_])archive([^[:alnum:]_]|$)/) failed = 1
        if (code ~ /(^|[[:space:]\\])CODE_SIGNING_ALLOWED=NO([^[:alnum:]_]|$)/) unsigned = 1
        if (code !~ /\\[[:space:]]*$/) finish_command()
      }
    }
    END {
      finish_command()
      if (seen == 0 || failed) exit 1
    }
  ' "$1"
}
if ! check_unsigned_xcodebuilds build.sh; then
  echo "error: every routine local xcodebuild command must include CODE_SIGNING_ALLOWED=NO" >&2
  exit 1
fi
if ! check_unsigned_xcodebuilds .github/workflows/ci.yml; then
  echo "error: every routine CI xcodebuild command must include CODE_SIGNING_ALLOWED=NO" >&2
  exit 1
fi
for file in build.sh .github/workflows/ci.yml; do
  if awk '$0 !~ /^[[:space:]]*#/' "$file" \
    | rg -qi '(^|[^[:alnum:]_])archive([^[:alnum:]_]|$)'; then
    echo "error: routine unsigned build entrypoint must not contain an archive action: $file" >&2
    exit 1
  fi
done
signing_operation_files=''
for file in $automation_files; do
  if [ "$file" != 'Scripts/check-release-readiness.sh' ] \
    && awk '$0 !~ /^[[:space:]]*#/' "$file" \
      | rg -qi '(^|[^[:alnum:]_])security([^[:alnum:]_]|$)|CODE_SIGNING_ALLOWED=YES|CODE_SIGN_IDENTITY|PROVISIONING_PROFILE|exportArchive|-archivePath|codesign|productbuild|productsign|notarytool|stapler|secrets[[:space:]]*(\.|\[|:)|(^|[^[:alnum:]_])(match|cert|sigh|gym|build_app|sync_code_signing|get_certificates|get_provisioning_profile|upload_to_app_store|upload_to_testflight|pilot|deliver|app_store_connect_api_key)[[:space:]]*(\(|$)'; then
    if [ -n "$signing_operation_files" ]; then
      signing_operation_files="$signing_operation_files
$file"
    else
      signing_operation_files=$file
    fi
  fi
done
if [ -n "$signing_operation_files" ]; then
  printf '%s\n' "$signing_operation_files" | sort -u >&2
  echo "error: routine CI must not import or use signing credentials" >&2
  exit 1
fi
grep -Fq '[code-signing policy](docs/CODE_SIGNING.md)' CONTRIBUTING.md
grep -Fq '[code-signing policy](docs/CODE_SIGNING.md)' SECURITY.md
grep -Fq '[code-signing policy](CODE_SIGNING.md)' docs/RELEASE.md
grep -Fq 'Apple Developer Team ID: `94HVVWXLK3`' docs/CODE_SIGNING.md
grep -Fq '`Developer ID Application` is for macOS software distributed outside the Mac App Store.' docs/CODE_SIGNING.md
grep -Fq '| App bundle identifier | `com.hinoshiba.bameyasu` |' docs/BRAND_AUDIT.md
grep -Fq '| Test bundle identifier | `com.hinoshiba.bameyasu.tests` |' docs/BRAND_AUDIT.md
grep -Fq '| Apple bundle lookup | `com.hinoshiba.bameyasu` |' docs/BRAND_AUDIT.md
grep -Fq 'App Store Connect record for `com.hinoshiba.bameyasu`' docs/BRAND_AUDIT.md
grep -Fq 'DispatchQueue(label: "com.hinoshiba.bameyasu.camera.session")' Bameyasu/Services/LightMeter.swift
grep -Fq 'DispatchQueue(label: "com.hinoshiba.bameyasu.camera.samples"' Bameyasu/Services/LightMeter.swift
grep -Fq 'queue.name = "com.hinoshiba.bameyasu.motion"' Bameyasu/Services/MotionMeter.swift
grep -q 'https://github.com/hinoshiba/Bameyasu' Bameyasu/Views/SettingsView.swift
test -x ci_scripts/ci_pre_xcodebuild.sh

if find . -maxdepth 3 -type f \( -name Package.resolved -o -name Podfile.lock -o -name Cartfile.resolved \) | grep -q .; then
  echo "error: dependency lockfile found; update THIRD_PARTY_NOTICES.txt and this audit gate" >&2
  exit 1
fi

dimensions=$(sips -g pixelWidth -g pixelHeight -g hasAlpha \
  Bameyasu/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png 2>/dev/null)
echo "$dimensions" | grep -q 'pixelWidth: 1024'
echo "$dimensions" | grep -q 'pixelHeight: 1024'
echo "$dimensions" | grep -q 'hasAlpha: no'

echo "release-readiness checks passed"
