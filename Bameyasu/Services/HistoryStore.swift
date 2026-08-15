import Foundation

@MainActor
final class HistoryStore: ObservableObject {
    @Published private(set) var assessments: [EnvironmentAssessment] = []

    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(fileManager: FileManager = .default) {
        let support = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        let directory = support.appendingPathComponent("Bameyasu", isDirectory: true)
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        fileURL = directory.appendingPathComponent("assessments.json")

        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        load()
    }

    func add(_ assessment: EnvironmentAssessment) {
        assessments.insert(assessment, at: 0)
        assessments = Array(assessments.prefix(100))
        save()
    }

    func delete(at offsets: IndexSet) {
        assessments.remove(atOffsets: offsets)
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let saved = try? decoder.decode([EnvironmentAssessment].self, from: data) else { return }
        assessments = saved.sorted { $0.measuredAt > $1.measuredAt }
    }

    private func save() {
        guard let data = try? encoder.encode(assessments) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
