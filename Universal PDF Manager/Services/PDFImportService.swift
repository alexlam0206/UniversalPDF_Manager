//
//  PDFImportService.swift
//  Universal PDF Manager
//

import Foundation
import UniformTypeIdentifiers

enum PDFImportError: Error {
    case accessDenied
}

@available(macOS 14.0, *)
final class PDFImportService {
    static let shared = PDFImportService()

    private init() {}

    @available(macOS 14.0, *)
    func importPDFs(urls: [URL]) async throws -> [PDFDocumentRecord] {
        var records: [PDFDocumentRecord] = []
        for url in urls {
            guard url.startAccessingSecurityScopedResource() else { throw PDFImportError.accessDenied }
            defer { url.stopAccessingSecurityScopedResource() }

            let (text, pageCount, title, author) = PDFTextExtractor.extract(from: url)
            var finalText = text
            var ocrUsed = false
            var languages: [String] = []

            if finalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                do {
                    finalText = try await OCREngine.shared.recognizeText(from: url, languages: ["en-US", "zh-Hant", "zh-Hans"])
                    ocrUsed = true
                    languages = ["en", "zh-Hant", "zh-Hans"]
                } catch {
                    finalText = ""
                }
            }

            let suggested = TagSuggestionService.shared.suggestTags(text: finalText)

            let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
            let fileSize = (attributes?[.size] as? NSNumber)?.int64Value ?? 0

            let bookmark = try? FileBookmarkService.shared.createBookmark(for: url)

            let record = PDFDocumentRecord(
                fileName: url.lastPathComponent,
                originalURLBookmark: bookmark,
                storedURLBookmark: bookmark,
                fileSizeBytes: fileSize,
                pageCount: pageCount,
                createdAt: .now,
                updatedAt: .now,
                detectedLanguageCodes: languages,
                ocrPerformed: ocrUsed,
                ocrLanguages: languages,
                title: title,
                author: author,
                year: parseYear(from: finalText),
                vendor: parseVendor(from: finalText),
                invoiceDate: parseDate(from: finalText),
                amount: parseAmount(from: finalText),
                passenger: parsePassenger(from: finalText),
                airline: parseAirline(from: finalText),
                flightDate: parseFlightDate(from: finalText),
                contentTextSnippet: String(finalText.prefix(4000)),
                tags: suggested,
                userNotes: nil,
                spotlightIndexed: false
            )

            records.append(record)
        }
        return records
    }

    private func parseYear(from text: String) -> Int? {
        let regex = try? NSRegularExpression(pattern: "\\b(20[0-9]{2}|19[0-9]{2})\\b")
        if let match = regex?.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) {
            if let range = Range(match.range(at: 1), in: text) { return Int(text[range]) }
        }
        return nil
    }

    private func parseAmount(from text: String) -> Double? {
        let regex = try? NSRegularExpression(pattern: "(USD|HKD|\\$)\\s?([0-9]+(\\.[0-9]{2})?)", options: [.caseInsensitive])
        if let match = regex?.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) {
            if let range = Range(match.range(at: 2), in: text) { return Double(text[range]) }
        }
        return nil
    }

    private func parseVendor(from text: String) -> String? {
        // Heuristic: first line with keywords
        for line in text.components(separatedBy: .newlines).prefix(10) {
            if line.lowercased().contains("invoice") { continue }
            if line.trimmingCharacters(in: .whitespaces).count > 2 { return line.trimmingCharacters(in: .whitespaces) }
        }
        return nil
    }

    private func parseDate(from text: String) -> Date? {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
        let range = NSRange(text.startIndex..., in: text)
        let date = detector?.matches(in: text, options: [], range: range).first?.date
        return date
    }

    private func parsePassenger(from text: String) -> String? {
        let keywords = ["passenger", "name:"]
        for line in text.components(separatedBy: .newlines) {
            let lower = line.lowercased()
            if let key = keywords.first(where: { lower.contains($0) }) {
                if let idx = lower.range(of: key)?.upperBound {
                    let name = line[idx...].trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: ":- "))
                    if !name.isEmpty { return name }
                }
            }
        }
        return nil
    }

    private func parseAirline(from text: String) -> String? {
        let known = ["Cathay", "United", "Delta", "American", "Lufthansa", "Emirates", "Singapore", "Qantas"]
        for brand in known where text.contains(brand) { return brand }
        return nil
    }

    private func parseFlightDate(from text: String) -> Date? {
        return parseDate(from: text)
    }
} 