//
//  PDFNumberingService.swift
//  Universal PDF Manager
//

import Foundation
import PDFKit
import AppKit

enum PDFNumberingPosition { case topLeft, topCenter, topRight, bottomLeft, bottomCenter, bottomRight }

enum PDFNumberingService {
    static func addPageNumbers(urlBookmark: Data?, range: Range<Int>? = nil, format: String = "%d", position: PDFNumberingPosition = .bottomCenter, font: NSFont = .systemFont(ofSize: 11), color: NSColor = .secondaryLabelColor, margin: CGFloat = 16) {
        guard let url = FileBookmarkService.shared.url(from: urlBookmark), let doc = PDFDocument(url: url) else { return }
        let total = doc.pageCount
        let r = range ?? 0..<total
        for i in r {
            guard let page = doc.page(at: i) else { continue }
            let label = String(format: format, i+1)
            let bounds = page.bounds(for: .mediaBox)
            let size = (label as NSString).size(withAttributes: [.font: font])
            let origin: CGPoint
            switch position {
            case .topLeft: origin = CGPoint(x: margin, y: bounds.height - size.height - margin)
            case .topCenter: origin = CGPoint(x: (bounds.width - size.width)/2, y: bounds.height - size.height - margin)
            case .topRight: origin = CGPoint(x: bounds.width - size.width - margin, y: bounds.height - size.height - margin)
            case .bottomLeft: origin = CGPoint(x: margin, y: margin)
            case .bottomCenter: origin = CGPoint(x: (bounds.width - size.width)/2, y: margin)
            case .bottomRight: origin = CGPoint(x: bounds.width - size.width - margin, y: margin)
            }
            let annot = PDFAnnotation(bounds: CGRect(origin: origin, size: size), forType: .freeText, withProperties: nil)
            annot.contents = label
            annot.font = font
            annot.fontColor = color
            annot.color = .clear
            page.addAnnotation(annot)
        }
        doc.write(to: url)
    }
} 