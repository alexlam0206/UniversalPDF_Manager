//
//  PDFTextExtractor.swift
//  Universal PDF Manager
//

import Foundation
import PDFKit

struct PDFTextExtractor {
    static func extract(from url: URL) -> (text: String, pageCount: Int, title: String?, author: String?) {
        guard let doc = PDFDocument(url: url) else { return ("", 0, nil, nil) }
        var fullText = ""
        for i in 0..<(doc.pageCount) {
            if let page = doc.page(at: i), let str = page.string {
                fullText += str + "\n"
            }
        }
        let title = doc.documentAttributes?[PDFDocumentAttribute.titleAttribute] as? String
        let author = doc.documentAttributes?[PDFDocumentAttribute.authorAttribute] as? String
        return (fullText.trimmingCharacters(in: .whitespacesAndNewlines), doc.pageCount, title, author)
    }
} 