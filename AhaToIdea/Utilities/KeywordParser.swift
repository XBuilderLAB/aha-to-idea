import Foundation

struct KeywordParser {
    static func parse(_ text: String) -> [String] {
        let separators = CharacterSet(charactersIn: " ,，、；;\n")
        let words = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: separators)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        return words
    }
}
