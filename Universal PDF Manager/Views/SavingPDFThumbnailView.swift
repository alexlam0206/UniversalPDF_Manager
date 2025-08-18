//
//  SavingPDFThumbnailView.swift
//  Universal PDF Manager
//

import AppKit
import PDFKit

final class SavingPDFThumbnailView: PDFThumbnailView {
    override func draggingEnded(_ sender: NSDraggingInfo) {
        super.draggingEnded(sender)
        saveDocumentIfPossible()
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let ok = super.performDragOperation(sender)
        if ok { saveDocumentIfPossible() }
        return ok
    }

    private func saveDocumentIfPossible() {
        guard let doc = self.pdfView?.document, let url = doc.documentURL else { return }
        doc.write(to: url)
    }
} 