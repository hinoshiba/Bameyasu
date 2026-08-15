# License and Commercial Distribution Audit

Audit date: 2026-08-15

## Conclusion

The current composition supports both public MIT source distribution and paid App Store binary distribution.

| Component | Version/source | Distributed in binary | License/status | Decision |
|---|---|---:|---|---|
| Bameyasu Swift source | repository | yes | MIT, © 2026 hinoshiba | commercial/OSS allowed |
| Runtime third-party packages | none | no | n/a | lowest supply-chain risk |
| Apple SDK frameworks | Xcode SDK | platform-linked | Apple agreements | Apple-platform app use only |
| SF Symbols | OS/SDK | rendered by system | Apple terms | UI only; never logo/icon/trademark |
| App icon | `Scripts/MakeIcon.swift` | yes | original geometric art | covered by project policy |
| XcodeGen | build-time tool | no | MIT | allowed; not a runtime notice obligation |
| Public guidance summaries | `SOURCES.md` | text facts/links | source-specific | independent short summary + attribution |

The MIT grant covers the repository's code and documentation, not permission to
market a modified product under the Bameyasu identity. `TRADEMARKS.md` keeps
copyright licensing and source-identifying trademark rights separate so forks
can remain commercially usable without implying official sponsorship.

## Policy for new code and assets

Allowed by default after notice review: MIT, Apache-2.0, BSD-2/3-Clause, ISC, Zlib, CC0; OFL-1.1 for fonts; CC BY 4.0 for assets when attribution is practical.

Requires explicit maintainer/legal review: GPL, AGPL, LGPL, CC BY-SA, ODbL, MPL, proprietary SDK terms, AI-generated assets with unclear provenance, and anything with a custom license.

Rejected by default: `No license`, research-only, education-only, personal-use-only, CC BY-NC, CC BY-ND, SSPL, BUSL, Commons Clause, scraped/unknown assets, or licenses that prohibit paid distribution.

## Public-source rules

- Do not paste ISO/JIS/CIE/WHO text, tables, translations, or diagrams without document-specific commercial permission.
- Prefer facts from legislation and public agencies, rewrite in original language, identify processing by Bameyasu, link the free official source, and never use agency logos.
- Do not say that a source organization approves or certifies Bameyasu.

## Release gate

Every release must:

1. inventory SPM, CocoaPods, binary frameworks, fonts, images, sounds, models, and copied text;
2. record exact versions and official origins;
3. confirm permission for commercial App Store distribution and public-source redistribution;
4. update `THIRD_PARTY_NOTICES.txt` with required full notices;
5. ensure dependency code is not silently embedded by an SDK;
6. run `Scripts/check-release-readiness.sh`;
7. archive the audit with the release tag.
8. verify that modified distributions follow `TRADEMARKS.md` and use a distinct
   name, bundle identifier, icon, and store listing unless permission was given.

This is an engineering compliance record, not legal advice. Material licensing uncertainty must block release pending qualified counsel.
