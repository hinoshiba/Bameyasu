# Product and App Store Strategy

## Positioning

Bameyasu is not a sensor dashboard. Its promise is:

> 60秒で、仕事場の「まず直す1つ」がわかる。

The name is pronounced `バメヤス` and combines the Japanese ideas `場` (the
place where work happens) and `目安` (a practical reference). This reinforces
the product's refusal to present estimates as medical, calibrated, or
compliance measurements.

The brand voice is calm, evidence-aware, and practical rather than clinical or
alarmist. Use the spelling `Bameyasu` consistently. See `BRAND_AUDIT.md`.

The first release optimizes a tight loop:

```text
check → one practical action → adjust the desk → recheck → see improvement → start focused work
```

Ranking first cannot be guaranteed. The controllable goal is a trustworthy product with a high first-check completion rate, useful repeat behavior, strong accessibility, low crash/permission abandonment, and honest store conversion.

## Release 0.1 feature set

- permission-at-point-of-use onboarding;
- 60-second guided light, sound, desk, and ergonomics flow;
- partial completion when a permission is denied;
- “fix this first” result;
- on-device history and trend chart;
- 50-minute focus timer and 10-minute work-break prompt;
- opt-in result sharing without raw sensor data;
- in-app methodology, evidence, privacy, terms, and license access;
- Japanese and English UI behavior, Dynamic Type, VoiceOver labels, and Reduce Motion.

## App Store product page

- Product name: `Bameyasu – 仕事環境チェック`
- English product name: `Bameyasu – Workspace Check`
- Launch copy: `場の目安。仕事環境を、測って整える。`
- Subtitle: `光・音・姿勢を60秒で見える化`
- Category: Productivity
- Screenshot 1: `60秒で、まず直す1つがわかる`
- Screenshot 2: `光・音・机を端末上で解析`
- Screenshot 3: `改善して、その場で再チェック`
- Screenshot 4: `根拠と測定確度をすべて公開`
- Screenshot 5: `画像も音声も保存・送信しない`

Avoid “medical,” “diagnosis,” “certified,” “safe,” “legal compliance,” and accuracy claims without published validation. Do not use third-party brand names as keywords.

## Metrics without surveillance

Bameyasu intentionally has no analytics SDK in 0.1. Product decisions should begin with opt-in TestFlight interviews and App Store Connect aggregate metrics. If first-party telemetry is later proposed, it requires a separate consent, data-minimization, retention, privacy, security, and App Store disclosure review before code is added.

Product-page optimization should test only one asset change at a time. Apple states that search discovery considers text relevance and user behavior such as downloads and ratings; useful completion and retention matter more than keyword stuffing: https://developer.apple.com/app-store/discoverability/

## Ethical rating prompt

Do not prompt during onboarding, permission requests, a failed scan, a warning, or immediately after a low result. A future rating prompt may be considered only after at least three completed checks or a measurable improvement after rechecking. The user must always be able to dismiss it.

## Roadmap gates

### 0.2 — improvement loop

- recheck a single metric;
- label workspaces without location permission;
- compare morning/evening and before/after;
- resume a partially interrupted scan;
- local work-break notifications requested only when the user enables a schedule.

### 0.3 — validation

- multi-device lux study against a traceable lux meter;
- multi-device acoustic study against a Class 1/2 reference chain;
- publish bias, repeatability, limits of agreement, supported configurations, and failure ranges;
- only then reconsider numeric accuracy wording and scoring inclusion.

### 0.4 — external environment sensors

- BLE import for temperature, humidity, and CO₂ only from documented devices;
- preserve the external device's calibration date and accuracy metadata;
- never convert VOC proxy values into CO₂ or claim whole-room air quality;
- re-audit every device SDK and cloud dependency license/privacy behavior.

### Later experiments

- TrueDepth face-to-device distance only when the iPhone is deliberately mounted beside the work display and the geometry is explained;
- LiDAR-guided desk/monitor dimensions on supported devices;
- flicker indication as an experimental, non-scored signal after camera-model validation.

Color temperature “health scores,” electromagnetic-safety claims, camera-based CO₂/PM/VOC/UV, and universal neck-angle or sitting-time health thresholds remain out of scope.
