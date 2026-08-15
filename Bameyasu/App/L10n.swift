import Foundation

enum L10n {
    static var isJapanese: Bool {
        Locale.preferredLanguages.first?.hasPrefix("ja") ?? true
    }

    static func text(_ japanese: String, _ english: String) -> String {
        isJapanese ? japanese : english
    }

    static func formatted(_ japanese: String, _ english: String, _ arguments: CVarArg...) -> String {
        String(format: text(japanese, english), locale: Locale.current, arguments: arguments)
    }
}
