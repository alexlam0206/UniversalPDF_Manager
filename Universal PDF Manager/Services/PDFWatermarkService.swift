//
//  PDFWatermarkService.swift
//  Universal PDF Manager
//

import Foundation
import PDFKit
import AppKit

enum PDFWatermarkService {
    static func applyTextWatermark(urlBookmark: Data?, text: String, font: NSFont = .systemFont(ofSize: 36, weight: .bold), color: NSColor = NSColor.black.withAlphaComponent(0.15), at point: CGPoint? = nil) {
        guard let url = FileBookmarkService.shared.url(from: urlBookmark), let doc = PDFDocument(url: url) else { return }
        for i in 0..<doc.pageCount {
            guard let page = doc.page(at: i) else { continue }
            let bounds = page.bounds(for: .mediaBox)
            let size = (text as NSString).size(withAttributes: [.font: font])
            let origin = point ?? CGPoint(x: (bounds.width - size.width)/2, y: (bounds.height - size.height)/2)
            let annotation = PDFAnnotation(bounds: CGRect(origin: origin, size: size), forType: .freeText, withProperties: nil)
            annotation.contents = text
            annotation.font = font
            annotation.fontColor = color
            annotation.alignment = .center
            annotation.color = .clear
            page.addAnnotation(annotation)
        }
        doc.write(to: url)
    }
}

private extension NSImage {
    func withAlphaComponent(_ alpha: CGFloat) -> NSImage {
        let img = NSImage(size: size)
        img.lockFocus()
        draw(in: CGRect(origin: .zero, size: size), from: .zero, operation: .sourceOver, fraction: alpha)
        img.unlockFocus()
        return img
    }
} 