import XCTest
@testable import Bameyasu

final class AssessmentEngineTests: XCTestCase {
    func testLightAtMinimumGuidelineGetsFullIlluminationScore() {
        let result = AssessmentEngine.lightResult(lux: 300, contrastRatio: 1.5)
        XCTAssertEqual(result.score, 100)
        XCTAssertEqual(result.confidence, .estimated)
    }

    func testStrongContrastReducesLightScoreSeparately() {
        let result = AssessmentEngine.lightResult(lux: 500, contrastRatio: 4.2)
        XCTAssertEqual(result.score, 80)
    }

    func testUncalibratedSoundIsAlwaysMarkedEstimated() {
        let result = AssessmentEngine.noiseResult(decibels: 88, isCalibrated: false)
        XCTAssertEqual(result.confidence, .estimated)
        XCTAssertTrue(result.unit.contains("*"))
    }

    func testComparisonCalibratedSoundIsMarkedCalibrated() {
        let result = AssessmentEngine.noiseResult(decibels: 55, isCalibrated: true)
        XCTAssertEqual(result.confidence, .calibrated)
    }

    func testOverallScoreExcludesUncalibratedSoundAndVibration() {
        let light = metric(kind: .light, score: 80, confidence: .estimated)
        let noise = metric(kind: .noise, score: 10, confidence: .estimated)
        let stability = metric(kind: .stability, score: 10, confidence: .estimated)
        let ergonomics = metric(kind: .ergonomics, score: 60, confidence: .guidance)

        let result = AssessmentEngine.assessment(metrics: [light, noise, stability, ergonomics], checks: [])
        XCTAssertEqual(result.score, 72)
        XCTAssertEqual(result.algorithmVersion, "0.1.0")
    }

    func testUnavailableMetricDoesNotCountAsGoodOrZero() {
        let light = metric(kind: .light, score: 100, confidence: .estimated)
        let unavailable = AssessmentEngine.unavailable(kind: .ergonomics, reason: "not measured")
        let result = AssessmentEngine.assessment(metrics: [light, unavailable], checks: [])
        XCTAssertEqual(result.score, 100)
        XCTAssertFalse(result.hasSufficientCoverage)
    }

    func testCoverageRequiresBothLightAndErgonomics() {
        let light = metric(kind: .light, score: 90, confidence: .estimated)
        let ergonomics = metric(kind: .ergonomics, score: 80, confidence: .guidance)
        let result = AssessmentEngine.assessment(metrics: [light, ergonomics], checks: [])
        XCTAssertTrue(result.hasSufficientCoverage)
    }

    func testAssessmentRoundTripsThroughJSON() throws {
        let original = AssessmentEngine.assessment(
            metrics: [metric(kind: .light, score: 90, confidence: .estimated)],
            checks: []
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let data = try encoder.encode(original)
        let decoded = try decoder.decode(EnvironmentAssessment.self, from: data)
        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.score, original.score)
        XCTAssertEqual(decoded.metrics, original.metrics)
        XCTAssertEqual(decoded.recommendations, original.recommendations)
        XCTAssertEqual(decoded.algorithmVersion, original.algorithmVersion)
        XCTAssertEqual(decoded.measuredAt.timeIntervalSince1970, original.measuredAt.timeIntervalSince1970, accuracy: 1)
    }

    private func metric(
        kind: MetricKind,
        score: Int,
        confidence: MeasurementConfidence
    ) -> MetricResult {
        MetricResult(
            kind: kind,
            value: Double(score),
            unit: "",
            score: score,
            summary: "",
            detail: "",
            confidence: confidence,
            sourceIDs: []
        )
    }
}
