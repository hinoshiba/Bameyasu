# Measurement Methodology

Algorithm version: **0.1.0**
Last reviewed: **2026-08-15**

This document is part of the product. Any change to a formula, threshold, weight, sampling duration, wording, or sensor path must update the algorithm version, tests, this document, and release notes.

## Scope

Bameyasu is a screening and coaching tool. It intentionally distinguishes:

- official reference values from public sources;
- camera/microphone estimates;
- user-confirmed self-checks;
- Bameyasu-specific heuristics;
- measurements that iPhone cannot perform reliably.

Unmeasured items are shown as unmeasured, not good and not zero.

## Estimated work-surface illuminance

Duration: 10 seconds. The rear wide camera runs continuous auto exposure with no frame saved.

For each sampled frame, Bameyasu reads the camera exposure duration `t`, ISO sensitivity `S`, and fixed lens aperture `N`. It calculates:

```text
EV100 = log2(N² / t) - log2(S / 100)
estimatedLux = 2.5 × 2^EV100
```

The estimate is averaged over recent stable frames. This is a reflected-light exposure approximation, not direct access to the iPhone ambient-light sensor and not a calibrated incident-light measurement. Surface reflectance, light spectrum, HDR behavior, camera generation, case, angle, and auto-exposure affect it.

Bameyasu compares the estimate with the Japanese reference of 300 lx for ordinary office work, but phrases the result as “estimated” and never as legal compliance. A result below 300 lx receives a gradual Bameyasu score; 300 lx or more receives no high-lux penalty because the official rule supplies a minimum, not a universal upper health limit.

### Relative contrast

Bameyasu samples average luma in nine frame regions and computes `max / max(min, 12)`. Ratios below 2.5, 2.5–4, and 4 or more produce Bameyasu-specific penalties of 0, 8, and 20 points. These cutoffs are a conservative screening heuristic, not luminance-meter measurement or formal glare evaluation. A detected difference is worded as a possible contrast/glare issue.

## Reference sound level

Duration: 15 seconds. Audio is captured as 48 kHz PCM in AVAudioSession measurement mode, processed in memory, and discarded. Speech recognition is not used and no audio file is created.

Bameyasu applies a digital A-weighting response at 48 kHz, calculates RMS energy, converts it to dBFS, applies a generic 100 dB reference offset plus a user trim, and energy-averages recent blocks:

```text
blockLevel = 20 × log10(A-weighted RMS) + 100 + userTrim
referenceEquivalentLevel = 10 × log10(mean(10^(blockLevel / 10)))
```

The `100` offset is not universal hardware calibration. Before the user confirms comparison with a calibrated reference meter, the UI displays `参考 dB*`, marks confidence as “estimated,” and excludes sound from the overall readiness score. It must not be described as a dBA measurement.

After same-position comparison with a calibrated meter, the user can enter the difference and confirm comparison calibration. The result becomes `参考 dBA`, but still does not become a Type/Class compliant sound-level meter or statutory measurement. Microphone path changes, Bluetooth/headset input, cases, wind, clipping, low-frequency response, and device generation can invalidate the trim.

Bameyasu's 45/55/65/75/85 bands are product heuristics used to order improvement guidance. Only a comparison-calibrated result at or above 85 references the NIOSH occupational 8-hour context, and it immediately tells the user to reduce exposure and verify with a calibrated meter or professional. A 15-second reading is not an 8-hour time-weighted exposure measurement.

## Desk vibration and tilt

Duration: 8 seconds. Core Motion provides fused user acceleration and gravity at 30 Hz. Bameyasu calculates root-mean-square user acceleration. It uses product-only bands of 0.006, 0.02, and 0.05 g RMS to help find wobble or vibrating equipment.

Desk vibration is not a medical, safety, or structural assessment and is excluded from the overall readiness score. Tilt is descriptive only.

## Ergonomic self-check

The checklist asks whether the screen is roughly 40 cm or more away, the screen top is no higher than eye level, shoulders are relaxed, elbows are close, the back and feet are supported, glare is absent, and work can be broken up within an hour. An unchecked item means “not confirmed,” not necessarily “bad.”

## Workspace readiness score

The score is named **workspace readiness / 環境の整い度**, never health score or safety score.

```text
estimated light:          60%
ergonomic self-check:     40%
comparison-calibrated sound: +35% when available
desk vibration:           excluded
```

Available weights are normalized to 100. Unavailable values are omitted. This is Bameyasu's own prioritization heuristic and not a medical, legal, scientific, or public-agency index. A high score means only that the items Bameyasu could check were within its current guide.

## Not measured by iPhone alone

Bameyasu does not estimate temperature, humidity, CO₂, CO, PM2.5, VOC, formaldehyde, airflow, UV, electromagnetic-field safety, or air quality from unrelated sensors. These require appropriate external instruments and, where applicable, professional sampling methods.

## Validation status

Version 0.1.0 is an engineering prototype. Camera lux and sound reference values have not yet completed a multi-device validation study against traceable instruments. Before public App Store health/accuracy claims, run and publish a protocol covering supported iPhone models, orientations, light sources, sound levels/frequencies, reference instruments, sample size, bias, limits of agreement, repeatability, and failure conditions.
