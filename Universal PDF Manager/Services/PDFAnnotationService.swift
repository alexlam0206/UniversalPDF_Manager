//
//  PDFAnnotationService.swift
//  Universal PDF Manager
//

import Foundation
import PDFKit
import AppKit

enum PDFAnnotationService {
    static func highlight(urlBookmark: Data?, onPage pageIndex: Int, in rects: [CGRect]) {
        guard let url = FileBookmarkService.shared.url(from: urlBookmark), let doc = PDFDocument(url: url), let page = doc.page(at: pageIndex) else { return }
        for rect in rects {
            let annotation = PDFAnnotation(bounds: rect, forType: .highlight, withProperties: nil)
            annotation.color = NSColor.systemYellow.withAlphaComponent(0.4)
            page.addAnnotation(annotation)
        }
        doc.write(to: url)
    }

    static func addNote(urlBookmark: Data?, onPage pageIndex: Int, at rect: CGRect, contents: String) {
        guard let url = FileBookmarkService.shared.url(from: urlBookmark), let doc = PDFDocument(url: url), let page = doc.page(at: pageIndex) else { return }
        let annotation = PDFAnnotation(bounds: rect, forType: .freeText, withProperties: nil)
        annotation.contents = contents
        annotation.color = .clear
        annotation.font = .systemFont(ofSize: 12)
        annotation.fontColor = .labelColor
        page.addAnnotation(annotation)
        doc.write(to: url)
    }
} 