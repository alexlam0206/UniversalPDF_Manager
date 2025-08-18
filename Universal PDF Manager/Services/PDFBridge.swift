//
//  PDFBridge.swift
//  Universal PDF Manager
//

import Foundation
import PDFKit

final class PDFBridge: ObservableObject {
    @Published var pdfView: PDFView?

    func attach(_ view: PDFView) {
        self.pdfView = view
    }

    func reload(url: URL) {
        guard let v = pdfView else { return }
        v.document = PDFDocument(url: url)
    }

    func zoomIn() { pdfView?.zoomIn(nil) }
    func zoomOut() { pdfView?.zoomOut(nil) }
    func zoomToActual() { pdfView?.scaleFactor = 1.0 }

    func fitPage() {
        guard let v = pdfView else { return }
        v.autoScales = true
        v.scaleFactor = v.scaleFactorForSizeToFit
    }

    func fitWidth() {
        guard let v = pdfView else { return }
        v.autoScales = false
        v.minScaleFactor = 0.1
        v.maxScaleFactor = 10.0
        v.scaleFactor = v.scaleFactorForSizeToFit
    }

    func setDisplayMode(_ mode: PDFDisplayMode) { pdfView?.displayMode = mode }

    @discardableResult
    func search(_ query: String, caseSensitive: Bool = false) -> Int {
        guard let view = pdfView, let doc = view.document, !query.isEmpty else { return 0 }
        let options: NSString.CompareOptions = caseSensitive ? [] : .caseInsensitive
        let selections = doc.findString(query, withOptions: options)
        if let first = selections.first {
            view.setCurrentSelection(first, animate: true)
            view.scrollSelectionToVisible(self)
        }
        return selections.count
    }

    func goToPage(index: Int) {
        guard let v = pdfView, let doc = v.document, let page = doc.page(at: index) else { return }
        v.go(to: page)
    }

    func highlightCurrentSelection(color: NSColor = NSColor.systemYellow.withAlphaComponent(0.4)) {
        guard let v = pdfView, let selection = v.currentSelection else { return }
        for pageAny in selection.pages {
            guard let page = pageAny as? PDFPage else { continue }
            let bounds = selection.bounds(for: page)
            let annotation = PDFAnnotation(bounds: bounds, forType: .highlight, withProperties: nil)
            annotation.color = color
            page.addAnnotation(annotation)
        }
        v.document?.write(toFile: v.document?.documentURL?.path ?? "")
    }

    func movePage(from: Int, to: Int) {
        guard let doc = pdfView?.document,
              let page = doc.page(at: from) else { return }
        doc.removePage(at: from)
        doc.insert(page, at: max(0, min(to, doc.pageCount)))
    }
} 