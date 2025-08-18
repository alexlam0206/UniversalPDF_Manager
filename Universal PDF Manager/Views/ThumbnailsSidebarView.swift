//
//  ThumbnailsSidebarView.swift
//  Universal PDF Manager
//

import SwiftUI
import PDFKit

struct ThumbnailsSidebarView: NSViewRepresentable {
    var bridge: PDFBridge

    func makeNSView(context: Context) -> SavingPDFThumbnailView {
        let thumb = SavingPDFThumbnailView()
        thumb.backgroundColor = .clear
        thumb.thumbnailSize = CGSize(width: 120, height: 160)
        thumb.pdfView = bridge.pdfView
        thumb.allowsDragging = true
        thumb.allowsMultipleSelection = true
        return thumb
    }

    func updateNSView(_ nsView: SavingPDFThumbnailView, context: Context) {
        nsView.pdfView = bridge.pdfView
    }
} 