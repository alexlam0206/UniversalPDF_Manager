//
//  PDFRedactionService.swift
//  Universal PDF Manager
//

import Foundation
import PDFKit
import AppKit

enum PDFRedactionService {
    static func redact(urlBookmark: Data?, pageRects: [Int: [CGRect]], color: NSColor = .black) {
        guard let url = FileBookmarkService.shared.url(from: urlBookmark), let doc = PDFDocument(url: url) else { return }
        for (index, rects) in pageRects {
            guard let page = doc.page(at: index) else { continue }
            for r in rects {
                let annot = PDFAnnotation(bounds: r, forType: .square, withProperties: nil)
                annot.color = color
                annot.interiorColor = color
                page.addAnnotation(annot)
            }
        }
        doc.write(to: url)
    }
} 