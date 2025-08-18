//
//  ImagesToPDFService.swift
//  Universal PDF Manager
//

import Foundation
import PDFKit
import AppKit

enum ImagesToPDFService {
    static func makePDF(from images: [NSImage], destination: URL) throws {
        let pdf = PDFDocument()
        for (idx, img) in images.enumerated() {
            guard let tiff = img.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff) else { continue }
            let size = NSSize(width: rep.pixelsWide, height: rep.pixelsHigh)
            let page = PDFPage(image: img.resize(to: size))
            if let page = page { pdf.insert(page, at: idx) }
        }
        guard pdf.pageCount > 0 else { throw NSError(domain: "ImagesToPDF", code: 1) }
        pdf.write(to: destination)
    }
}

private extension NSImage {
    func resize(to size: NSSize) -> NSImage {
        let img = NSImage(size: size)
        img.lockFocus()
        draw(in: NSRect(origin: .zero, size: size))
        img.unlockFocus()
        return img
    }
} 