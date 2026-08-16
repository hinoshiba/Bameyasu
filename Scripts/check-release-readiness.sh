#!/bin/sh
set -eu

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

grep -q '^name: Bameyasu$' project.yml
grep -q 'PRODUCT_BUNDLE_IDENTIFIER: com.hinoshiba.bameyasu$' project.yml
grep -q 'PRODUCT_BUNDLE_IDENTIFIER: com.hinoshiba.bameyasu.tests$' project.yml
grep -q 'https://github.com/hinoshiba/Bameyasu' Bameyasu/Views/SettingsView.swift

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
