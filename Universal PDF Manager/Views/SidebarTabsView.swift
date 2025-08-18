//
//  SidebarTabsView.swift
//  Universal PDF Manager
//

import SwiftUI
import PDFKit

struct SidebarTabsView: View {
    var bridge: PDFBridge
    @State private var selection: Int = 0

    var body: some View {
        VStack(spacing: 6) {
            Picker("", selection: $selection) {
                Text("Thumbnails").tag(0)
                Text("Outline").tag(1)
                Text("Annotations").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 8)

            Group {
                switch selection {
                case 0:
                    ThumbnailsSidebarView(bridge: bridge)
                case 1:
                    OutlineListView(bridge: bridge)
                default:
                    AnnotationListView(bridge: bridge)
                }
            }
        }
    }
}

private struct OutlineListView: View {
    var bridge: PDFBridge
    var body: some View {
        ScrollView {
            if let doc = bridge.pdfView?.document, let root = doc.outlineRoot {
                OutlineNodeView(node: root, bridge: bridge)
            } else {
                Text("No outline").foregroundStyle(.secondary).frame(maxWidth: .infinity, alignment: .center).padding(12)
            }
        }
    }
}

private struct OutlineNodeView: View {
    var node: PDFOutline
    var bridge: PDFBridge
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button(node.label ?? "(Untitled)") {
                if let page = node.destination?.page, let doc = bridge.pdfView?.document {
                    let index = doc.index(for: page)
                    bridge.goToPage(index: index)
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            ForEach(0..<(node.numberOfChildren), id: \.self) { idx in
                OutlineNodeView(node: node.child(at: idx)!, bridge: bridge)
                    .padding(.leading, 12)
            }
        }
    }
}

private struct AnnotationListView: View {
    var bridge: PDFBridge
    private struct Item: Identifiable { let id = UUID(); let pageIndex: Int; let type: String }
    private var items: [Item] {
        guard let doc = bridge.pdfView?.document else { return [] }
        var result: [Item] = []
        for i in 0..<doc.pageCount {
            let annots = doc.page(at: i)?.annotations ?? []
            for a in annots {
                let t = a.type ?? "Annotation"
                result.append(Item(pageIndex: i, type: t))
            }
        }
        return result
    }
    var body: some View {
        ScrollView {
            if items.isEmpty {
                Text("No annotations").foregroundStyle(.secondary).frame(maxWidth: .infinity, alignment: .center).padding(12)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(items) { item in
                        Button("Page \(item.pageIndex+1): \(item.type)") {
                            bridge.goToPage(index: item.pageIndex)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                    }
                }
            }
        }
    }
} 