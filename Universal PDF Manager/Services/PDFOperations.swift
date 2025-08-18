//
//  PDFOperations.swift
//  Universal PDF Manager
//

import Foundation
import PDFKit
import AppKit

enum PDFOperations {
    static func rotate(urlBookmark: Data?, degrees: Int) {
        guard let url = FileBookmarkService.shared.url(from: urlBookmark), let doc = PDFDocument(url: url) else { return }
        for i in 0..<doc.pageCount {
            if let page = doc.page(at: i) {
                page.rotation = (page.rotation + degrees) % 360
            }
        }
        doc.write(to: url)
    }

    static func compress(urlBookmark: Data?) {
        guard let url = FileBookmarkService.shared.url(from: urlBookmark), let doc = PDFDocument(url: url) else { return }
        doc.write(to: url)
    }

    static func exportImages(urlBookmark: Data?, scale: CGFloat = 2.0) {
        guard let url = FileBookmarkService.shared.url(from: urlBookmark), let doc = PDFDocument(url: url) else { return }
        let dir = url.deletingPathExtension().lastPathComponent + " Images"
        let outputDir = url.deletingLastPathComponent().appendingPathComponent(dir)
        try? FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)
        for i in 0..<doc.pageCount {
            guard let page = doc.page(at: i) else { continue }
            // Use thumbnail to get a rendered NSImage reliably
            let target = CGSize(width: 1024, height: 1448)
            let img = page.thumbnail(of: target, for: .mediaBox)
            if let tiff = img.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff), let data = rep.representation(using: .jpeg, properties: [.compressionFactor: 0.9]) {
                let file = outputDir.appendingPathComponent("page_\(i+1).jpg")
                try? data.write(to: file)
            }
        }
    }
} 