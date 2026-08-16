# Brand Name Audit

Audit date: 2026-08-15
Bundle identifier verification: 2026-08-16
Decision: **conditional go**
Selected name: **Bameyasu**
Japanese reading: **バメヤス**

## Decision

`Bameyasu` combines the Japanese ideas **場** (*ba*, the place where work
happens) and **目安** (*meyasu*, a practical reference). The name therefore
states the product's most important promise honestly: it gives people a useful
reference for improving a workspace without presenting an iPhone estimate as a
medical diagnosis, calibrated measurement, safety certification, or legal
compliance decision.

The name was selected after independent product, collision, and rename-surface
reviews. It is materially safer and more ownable than `Akari`, but this
engineering audit is not a legal clearance opinion. Commercial launch remains
conditional on professional trademark review and filing.

The independent launch-fit assessment was 76/100 for a Japan-first consumer
product, 64/100 for a global/B2B product, and 69/100 overall. These are
product-strategy scores, not legal-clearance scores.

Canonical brand system:

| Use | Value |
|---|---|
| Wordmark / icon label | `Bameyasu` |
| Japanese reading | `バメヤス` |
| English pronunciation guide | `bah-meh-yah-soo` |
| Japanese App Store name | `Bameyasu – 仕事環境チェック` |
| English App Store name | `Bameyasu – Workspace Check` |
| Japanese launch copy | `場の目安。仕事環境を、測って整える。` |
| English launch copy | `A practical reference for a better workspace.` |
| App bundle identifier | `com.hinoshiba.bameyasu` |
| Test bundle identifier | `com.hinoshiba.bameyasu.tests` |
| Xcode project / target / scheme / module | `Bameyasu` |
| Repository | `hinoshiba/Bameyasu` |
| Hashtag | `#Bameyasu` |

Both proposed App Store names fit Apple's 30-character name limit. Apple asks
developers to use a simple, memorable, distinctive name and not to imitate an
existing app name. See Apple's [App information reference](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information/).

## Search method and result

The search covered exact names, spacing and hyphen variants, likely
romanizations, Japanese pronunciation, first six-character and suffix stems,
related products, app stores, source/package namespaces, domains, and official
trademark databases. The snapshot can become stale immediately and does not
reserve any name.

| Surface | Query scope | Result |
|---|---|---|
| Apple iTunes Search API | Japan/US; `Bameyasu`, `バメヤス` | No exact app-name match |
| Apple bundle lookup | `com.hinoshiba.bameyasu` | No public listing in Japan or the US (rechecked 2026-08-16) |
| Google Play | Japan/US indexed listings | No exact app-name match |
| General web | Exact, quoted, spaced, hyphenated, and romanization variants | No exact software, sensor, health, or workplace brand |
| GitHub | Repository names and account names | No exact match; the shorter `bameya` account is already held and must not be used |
| Package registries | npm, PyPI, RubyGems, crates.io, pub.dev, NuGet, CocoaPods, Maven | No exact package match found |
| Domains | `.com`, `.net`, `.io`, `.app`, `.dev`, `.jp` | WHOIS/RDAP returned no registration record; this is not a reservation or purchase guarantee |
| J-PlatPat mark search | `BAMEYASU` exact | 0 results |
| J-PlatPat pronunciation similarity | `バメヤス` | 3 algorithmic results; classes 25, 35, and 10; no class 9/11/42/44 direct hit |
| USPTO wordmark search | `BAMEYASU`, `BAMEYA`, `BAMAYASU`, `BAMEIASU`, `BAMEYAZU`, `BAMEYAS` | 0 exact results |
| USPTO stem search | `CM:BAMEYAS*`, `CM:BAMEYA*` | 0 results |
| TMview | Partial `BAMEYASU` and `BAMEYAS` | 0 rows in the preliminary search |

Spelling and sound checks also included `Bame Yasu`, `Bame-Yasu`, `Bameyas`,
`Bameyazu`, `Bameyasso`, `Bameyasoo`, `Bamiyasu`, `Bameasu`, `バメヤース`,
`バミヤス`, `バメヤズ`, and `バメアス`. No same-field brand was found.

Primary official portals:

- [J-PlatPat trademark search](https://www.j-platpat.inpit.go.jp/t0100)
- [USPTO Trademark Search](https://tmsearch.uspto.gov/search/search-information)
- [EUIPO TMview](https://www.tmdn.org/tmview/)
- [WIPO Global Brand Database](https://www.wipo.int/en/web/global-brand-database/index)

TMview states that its results do not constitute an official register and have
no legal effect. WIPO recommends also checking national and regional registers.
WIPO was not automated because of its usage conditions; a manual search remains
part of the filing gate.

## Residual collisions and limitations

These findings do not presently justify rejection, but they must remain visible:

- `BAMEYA` is used as a place name in Cameroon and by unrelated transport and
  construction businesses. It shares the first six Latin characters but not the
  whole pronunciation, product category, or commercial impression.
- [Meyasu Pte Ltd](https://meyasu.com.sg/) is a Singapore supplier of food and
  bakery-processing machinery. It is not a workplace/sensor/software product,
  but ASEAN clearance should include its registrations and classes.
- The USPTO fuzzy search returned two live `BAEASU` class-9 registrations: US
  serial 87384099 / registration 5692357 for consumer electronic accessories,
  and serial 99081507 / registration 8019677 for vehicle electronics. The
  words differ visually and by two intended syllables, but a US attorney should
  assess them before filing and keep any class-9 specification focused on the
  downloadable workspace application.
- J-PlatPat returned pending application `BANEYA INTERNATIONAL`
  (2026-014950) as a similar pronunciation in class 35. It is not a direct
  class-9/42 collision, but future advertising, retail, or business-support
  services require review.
- Japanese speakers may not split an unexplained `バメヤス` into `場 + 目安`.
  English speakers may initially pronounce `Bame` as “baym.” The reading and
  launch copy must therefore appear consistently during onboarding and launch.
- Because `目安` is suggestive of the product benefit, protection may be
  narrower than for a word with no meaning. Never shorten the brand to `Bame`,
  `Bameya`, `Meyasu`, or `Yasu`.

## Candidate red-team record

The following table preserves the principal knockouts so the team does not
repeat an attractive but unsafe choice later.

| Name | Decision | Principal reason |
|---|---|---|
| Akari | Reject | Multiple exact apps, including a 2026 Health & Fitness app, plus established software and the JAXA mission; search ownership is unrealistic |
| Deskmetry | Reject | Near-identical `DeskMetrics` is active in recruitment software; the older desktop-app analytics service remains widely documented |
| Hakaroom | Reject | Earlier radiation-measurement-room use, person-name results, and a crowded `ハカル` measurement/software field |
| Bametry | Reject | Live class-09 `PAMETRIA` is one consonant away in J-PlatPat pronunciation search |
| Envotune | Reject | `Envo` directly provides building automation, monitoring software, and temperature/humidity/CO2 sensors; a live US mark covers office automation apps and sensors |
| Habimetry | Reject | Live US `HABI` covers home/office monitoring of air quality, humidity, ambient light, and noise with sensors in classes 9/42 |
| Kaitevia | Reject | Too close in form and field to Kaiterra indoor-air-quality sensors and software |
| Ambimetry | Reject | Too close to Ambimetrics software, electronics, IoT, and environmental measurement |
| Roometry | Reject | Exact mobile-app use and an active AI interior/furniture platform |
| Totonote | Reject | Exact App Store app and active online services |
| Sukoyvia | Reject | `SUKOYAKA` has already been used for an indoor temperature/humidity/light/motion health-monitoring service; other `SUKOY`/`Sukvia` uses add risk |
| Lianoviq | Reject | First six characters match active `LIANOVA`, a workplace HR/People Analytics software brand with class-09 coverage |
| Mavunora | Reject | Begins with active `MAVUNO`, used by AI and real-time sensor-data platforms |
| Ravunelo | Reject | Begins with active `RAVUNÉ`, including smart accessories/watches; `RAVANELLO` and Ravello add spelling/search noise |
| Qelvona | Reject | Same intended sound as `KELVON`; `KELVION` and class-09 `KELVORA` operate in lighting/HVAC/environmental technology |
| Qivonela | Reject | Begins with the exact active mobile-app name `Qivon`; `Kivon` is also used by software businesses |
| Lunemiq | Reject | Close to `LUMENIQ`/`LUMIQ` software and monitoring marks and to an active `Lunemi` health-technology service |
| Linomiq | Reject | Near `MIMIQ`, `LINQ`, `BIOLINQ`, `CLINOMIC`, and class-09/10 `RENAMIC` uses |
| DeskGauge | Reject | Exact phrase is used for a Welch Allyn desk blood-pressure gauge; the words are also descriptive and weak for software protection |
| Bashirabe | Reject | Contains `SHI-RA-BE`, already used for an environmental/workplace research field and sensor-based outdoor-work index |
| AnbaiNote | Reject | Exact `ANBAI` Health & Fitness app measures employee/personal condition and is too close in purpose |
| Kokochart | Reject | `KOKOCHI` directly names a temperature/humidity workplace monitoring and sensor platform |
| TsukueTune | Reject | `Desktune` is an active ergonomic desk-product brand with essentially the same meaning and market story |

Examples supporting the most important knockouts include the
[exact Akari Health & Fitness listing](https://apps.apple.com/jp/app/akari/id6782635939),
[Akari Software](https://akarisoftware.com/),
[DeskMetrics](https://www.deskmetrics.io/),
[Envo products](https://envo.no/en/products),
[Envo Sense](https://envo.no/en/products/envo-sense),
[the HABI US trademark record](https://tsdr.uspto.gov/#caseNumber=87366644&caseSearchType=US_APPLICATION&caseType=DEFAULT&searchType=statusSearch),
and [Kaiterra](https://www.kaiterra.com/).

## Brand behavior

Write the name as `Bameyasu` in prose and metadata. `BaMeyasu` may be used only
as a visual wordmark treatment; it is not an alternate product name. Use
`バメヤス` as the sole Japanese reading and `bah-meh-yah-soo` when an English
pronunciation guide is useful.

The brand should feel calm, candid, and actionable. It must identify estimate
quality, explain what the iPhone cannot measure, and recommend one reversible
improvement at a time. Do not use clinical imagery, fear-based alerts,
compliance badges, or claims such as “certified,” “safe,” “diagnosis,” “medical
grade,” “lux meter,” or “sound level meter.”

## Commercial launch gate

This audit is not legal advice and does not guarantee registrability,
non-infringement, domain availability, or App Store acceptance. Before public
commercial launch:

1. have a trademark attorney or Japanese patent attorney run a full similarity
   and common-law search, primarily for classes 09 and 42, and for classes 11,
   35, and 44 if the business plan reaches those goods/services;
2. manually complete WIPO and launch-country searches, including ASEAN and the
   `BAEASU`, `BAMEYA`, and `MEYASU` findings above;
3. file the `Bameyasu` word mark in launch markets before broad publicity where
   practical;
4. reserve `bameyasu` domains and social/developer handles; an unregistered
   lookup is not a reservation;
5. create the App Store Connect record for `com.hinoshiba.bameyasu` before the
   public announcement;
6. rerun this audit immediately before filing and before release.

Do not expand into medical-device or diagnostic positioning without a new
class-10 clearance, regulatory review, and validated measurement evidence.
