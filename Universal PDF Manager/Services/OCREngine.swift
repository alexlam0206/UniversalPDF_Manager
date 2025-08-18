//
//  OCREngine.swift
//  Universal PDF Manager
//

import Foundation
import Vision
import PDFKit
import AppKit

enum OCRError: Error {
    case renderingFailed
}

final class OCREngine {
    static let shared = OCREngine()

    private init() {}

    func recognizeText(from url: URL, languages: [String]) async throws -> String {
        guard let doc = PDFDocument(url: url) else { return "" }
        var result = ""
        for index in 0..<doc.pageCount {
            guard let page = doc.page(at: index) else { continue }
            let targetRect = page.bounds(for: .mediaBox)
            let img = NSImage(size: targetRect.size)
            img.lockFocus()
            NSColor.white.setFill()
            __NSRectFill(CGRect(origin: .zero, size: targetRect.size))
            page.draw(with: .mediaBox, to: NSGraphicsContext.current!.cgContext)
            img.unlockFocus()
            guard let cgImage = img.cgImage(forProposedRect: nil, context: nil, hints: nil) else { throw OCRError.renderingFailed }

            let request = VNRecognizeTextRequest()
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.recognitionLanguages = languages

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try handler.perform([request])
            let pageText = (request.results ?? []).compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
            result += pageText + "\n"
        }
        return result
    }
} 