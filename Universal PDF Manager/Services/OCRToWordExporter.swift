//
//  OCRToWordExporter.swift
//  Universal PDF Manager
//

import Foundation
import AppKit

enum OCRToWordExporter {
    static func export(urlBookmark: Data?, languages: [String]) async {
        guard let url = FileBookmarkService.shared.url(from: urlBookmark) else { return }
        do {
            let text = try await OCREngine.shared.recognizeText(from: url, languages: languages)
            let attributed = NSAttributedString(string: text, attributes: [
                .font: NSFont.systemFont(ofSize: 12)
            ])
            let rtfData = try attributed.data(from: NSRange(location: 0, length: attributed.length), documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf])
            let outURL = url.deletingPathExtension().appendingPathComponent("OCR Export.rtf")
            try FileManager.default.createDirectory(at: outURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try rtfData.write(to: outURL)
        } catch {
            print("OCR to RTF failed: \(error)")
        }
    }
} 