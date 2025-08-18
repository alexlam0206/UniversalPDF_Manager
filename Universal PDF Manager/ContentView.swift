//
//  ContentView.swift
//  Universal PDF Manager
//
//  Created by Alex Lam on 18/8/2025.
//

import SwiftUI
import SwiftData
import PDFKit
import AppKit
import UniformTypeIdentifiers

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.liquidGlass) private var glass
    @AppStorage("settings.ocrLanguages") private var ocrLanguages: String = "en-US,zh-Hant,zh-Hans"
    @StateObject private var pdfBridge = PDFBridge()
    @Query(sort: [SortDescriptor<PDFDocumentRecord>(\.updatedAt, order: .reverse)]) private var documents: [PDFDocumentRecord]

    @State private var searchText: String = ""
    @State private var selectedDocumentID: String?
    @State private var isImporting: Bool = false
    @State private var moveFromIndex: Int = 0
    @State private var moveToIndex: Int = 0
    @State private var showSearchPanel: Bool = false

    private var filteredDocuments: [PDFDocumentRecord] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return documents }
        let q = searchText.lowercased()
        return documents.filter { doc in
            if doc.fileName.lowercased().contains(q) { return true }
            if let title = doc.title?.lowercased(), title.contains(q) { return true }
            if let author = doc.author?.lowercased(), author.contains(q) { return true }
            if let vendor = doc.vendor?.lowercased(), vendor.contains(q) { return true }
            if let snippet = doc.contentTextSnippet?.lowercased(), snippet.contains(q) { return true }
            if doc.tags.contains(where: { $0.lowercased().contains(q) }) { return true }
            return false
        }
    }

    var body: some View {
        NavigationSplitView {
            sidebar
                .frame(minWidth: 220)
                .liquidGlassBackground(glass)
        } content: {
            list
                .liquidGlassBackground(glass)
        } detail: {
            detail
                .liquidGlassBackground(glass)
        }
        .navigationSplitViewColumnWidth(min: 220, ideal: 260)
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                Button { openImportPanel() } label: { Label("Import", systemImage: "tray.and.arrow.down") }
                    .help("Import PDFs")
                Button { NSPasteboard.general.clearContents() } label: { Label("Clear Clipboard", systemImage: "scissors") }
                    .help("Clear clipboard")

                Group {
                    Button { pdfBridge.zoomOut() } label: { Image(systemName: "minus.magnifyingglass") }
                    Button { pdfBridge.zoomToActual() } label: { Image(systemName: "1.magnifyingglass") }
                    Button { pdfBridge.zoomIn() } label: { Image(systemName: "plus.magnifyingglass") }
                    Button { pdfBridge.fitPage() } label: { Image(systemName: "rectangle.portrait") }.help("Fit Page")
                    Button { pdfBridge.fitWidth() } label: { Image(systemName: "rectangle.expand.vertical") }.help("Fit Width")
                }
                .help("Zoom controls")

                Button { showSearchPanel.toggle() } label: { Label("Search", systemImage: "magnifyingglass") }

                if let selected = documents.first(where: { $0.id == selectedDocumentID }) {
                    Button {
                        PDFAnnotationService.highlight(urlBookmark: selected.storedURLBookmark ?? selected.originalURLBookmark, onPage: 0, in: [CGRect(x: 100, y: 100, width: 200, height: 20)])
                        refreshSelected()
                    } label: { Label("Highlight", systemImage: "highlighter") }

                    Button {
                        Task {
                            let langs = ocrLanguages.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
                            await OCRToWordExporter.export(urlBookmark: selected.storedURLBookmark ?? selected.originalURLBookmark, languages: langs)
                        }
                    } label: { Label("OCR → RTF", systemImage: "doc.richtext") }

                    Menu("Tools") {
                        Button("Export Images") { doExportImages(for: selected) }
                        Button("Compress") { doCompress(for: selected) }
                        Divider()
                        Button("Add Page Numbers") { doAddPageNumbers(for: selected) }
                        Button("Add Watermark") { doAddWatermark(for: selected) }
                        Divider()
                        Button("Encrypt…") { doEncrypt(for: selected) }
                        Button("Decrypt…") { doDecrypt(for: selected) }
                        Divider()
                        Button("Images → PDF…") { doImagesToPDF() }
                        Button("Run Workflow") { doRunDefaultWorkflow(for: selected) }
                    }
                }
            }
        }
    }

    private var sidebar: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search PDFs, titles, tags…", text: $searchText)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.horizontal)
            .padding(.top)

            TagCloudView(allTags: collectAllTags(), onSelect: { tag in searchText = tag })
                .padding(.horizontal)
            Spacer()

            VStack(alignment: .leading, spacing: 8) {
                Text("Drag & Drop")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6, 6]))
                    .foregroundStyle(.secondary)
                    .overlay(Text("Drop PDFs here").padding(.vertical, 18))
                    .frame(maxWidth: .infinity, minHeight: 80)
                    .onDrop(of: [.fileURL], isTargeted: nil) { providers in handleDrop(providers: providers) }
            }
            .padding()
        }
    }

    private var list: some View {
        List(selection: $selectedDocumentID) {
            ForEach(filteredDocuments, id: \.id) { doc in
                HStack(spacing: 10) {
                    Image(systemName: "doc.richtext").font(.system(size: 18)).foregroundStyle(.tint)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(doc.title ?? doc.fileName).font(.headline)
                        HStack(spacing: 8) {
                            if let author = doc.author { Text(author).foregroundStyle(.secondary) }
                            if let vendor = doc.vendor { Text(vendor).foregroundStyle(.secondary) }
                            if let year = doc.year { Text(String(year)).foregroundStyle(.secondary) }
                        }
                        .font(.caption)
                    }
                    Spacer()
                    if !doc.tags.isEmpty { Text(doc.tags.joined(separator: ", ")).font(.caption2).foregroundStyle(.secondary) }
                }
                .tag(doc.id)
                .contextMenu {
                    Button("Rename") { renameDocument(doc) }
                    Button("Move to…") { moveDocument(doc) }
                }
            }
            .onDelete(perform: deleteDocuments)
        }
    }

    private var detail: some View {
        Group {
            if let selected = documents.first(where: { $0.id == selectedDocumentID }),
               let url = FileBookmarkService.shared.url(from: selected.storedURLBookmark ?? selected.originalURLBookmark) {
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        PDFKitView(url: url, bridge: pdfBridge)
                            .frame(minWidth: 420)
                        if showSearchPanel {
                            Divider()
                            SearchPanelView(bridge: pdfBridge)
                                .frame(maxHeight: 120)
                        }
                    }
                    Divider()
                    VStack(spacing: 8) {
                        SidebarTabsView(bridge: pdfBridge)
                            .frame(width: 220)
                        Divider()
                        InspectorView(document: binding(for: selected))
                            .frame(minWidth: 280, idealWidth: 320)
                    }
                    .frame(minWidth: 300)
                }
            } else {
                ContentUnavailableView("Select a PDF", systemImage: "doc.text.magnifyingglass", description: Text("Choose a document to preview and edit metadata"))
            }
        }
    }

    private func refreshSelected() {
        guard let selected = documents.first(where: { $0.id == selectedDocumentID }),
              let url = FileBookmarkService.shared.url(from: selected.storedURLBookmark ?? selected.originalURLBookmark) else { return }
        pdfBridge.reload(url: url)
    }

    // MARK: - Tool Actions

    private func doExportImages(for record: PDFDocumentRecord) {
        PDFOperations.exportImages(urlBookmark: record.storedURLBookmark ?? record.originalURLBookmark)
    }

    private func doCompress(for record: PDFDocumentRecord) {
        PDFOperations.compress(urlBookmark: record.storedURLBookmark ?? record.originalURLBookmark)
        refreshSelected()
    }

    private func doAddPageNumbers(for record: PDFDocumentRecord) {
        PDFNumberingService.addPageNumbers(urlBookmark: record.storedURLBookmark ?? record.originalURLBookmark)
        refreshSelected()
    }

    private func doAddWatermark(for record: PDFDocumentRecord) {
        PDFWatermarkService.applyTextWatermark(urlBookmark: record.storedURLBookmark ?? record.originalURLBookmark, text: "CONFIDENTIAL")
        refreshSelected()
    }

    private func doEncrypt(for record: PDFDocumentRecord) {
        // Simple prompt using NSSavePanel-style accessory is heavy; use fixed demo password here
        PDFSecurityService.encrypt(urlBookmark: record.storedURLBookmark ?? record.originalURLBookmark, options: PDFSecurityOptions(userPassword: "1234", ownerPassword: "owner"))
        refreshSelected()
    }

    private func doDecrypt(for record: PDFDocumentRecord) {
        PDFSecurityService.decrypt(urlBookmark: record.storedURLBookmark ?? record.originalURLBookmark, password: "1234")
        refreshSelected()
    }

    private func doImagesToPDF() {
        let open = NSOpenPanel()
        open.allowedContentTypes = [.png, .jpeg]
        open.allowsMultipleSelection = true
        open.canChooseDirectories = false
        open.begin { response in
            guard response == .OK else { return }
            let images: [NSImage] = open.urls.compactMap { NSImage(contentsOf: $0) }
            guard !images.isEmpty else { return }
            let save = NSSavePanel()
            save.allowedContentTypes = [.pdf]
            save.nameFieldStringValue = "Images.pdf"
            save.begin { r in
                guard r == .OK, let dest = save.url else { return }
                do { try ImagesToPDFService.makePDF(from: images, destination: dest) } catch { print("Images→PDF failed: \(error)") }
            }
        }
    }

    private func doRunDefaultWorkflow(for record: PDFDocumentRecord) {
        let wf = Workflow(id: UUID().uuidString, name: "Quick Flow", steps: [.compress, .textWatermark(text: "CONFIDENTIAL"), .addPageNumbers, .encrypt(user: "1234", owner: "owner")])
        WorkflowService.run(urlBookmark: record.storedURLBookmark ?? record.originalURLBookmark, workflow: wf)
        refreshSelected()
    }

    private func binding(for record: PDFDocumentRecord) -> Binding<PDFDocumentRecord> {
        guard let index = documents.firstIndex(where: { $0.id == record.id }) else { return .constant(record) }
        return Binding(
            get: { documents[index] },
            set: { updated in updated.updatedAt = .now }
        )
    }

    private func collectAllTags() -> [String] { Array(Set(documents.flatMap { $0.tags })).sorted() }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        let matched = providers.filter { $0.hasItemConformingToTypeIdentifier(UTType.pdf.identifier) || $0.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) }
        guard !matched.isEmpty else { return false }
        for provider in matched {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                if let url = item as? URL { Task { await importURLs([url]) } }
            }
        }
        return true
    }

    private func openImportPanel() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.pdf]
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.begin { response in if response == .OK { Task { await importURLs(panel.urls) } } }
    }

    private func importURLs(_ urls: [URL]) async {
        do {
            let records = try await PDFImportService.shared.importPDFs(urls: urls)
            await MainActor.run {
                for record in records { modelContext.insert(record) }
            }
        } catch { print("Import failed: \(error)") }
    }

    private func deleteDocuments(at offsets: IndexSet) { for index in offsets { modelContext.delete(filteredDocuments[index]) } }

    private func renameDocument(_ doc: PDFDocumentRecord) {
        guard let url = FileBookmarkService.shared.url(from: doc.storedURLBookmark ?? doc.originalURLBookmark) else { return }
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.pdf]
        panel.nameFieldStringValue = doc.title ?? doc.fileName
        panel.begin { response in
            if response == .OK, let dest = panel.url {
                do {
                    try FileManager.default.moveItem(at: url, to: dest)
                    doc.storedURLBookmark = try FileBookmarkService.shared.createBookmark(for: dest)
                    doc.fileName = dest.lastPathComponent
                    doc.updatedAt = .now
                    refreshSelected()
                } catch { print("Rename/move failed: \(error)") }
            }
        }
    }

    private func moveDocument(_ doc: PDFDocumentRecord) { renameDocument(doc) }
}

// MARK: - Inspector

private struct InspectorView: View {
    @Binding var document: PDFDocumentRecord

    @State private var newTag: String = ""

    var body: some View {
        Form {
            Section("Metadata") {
                TextField("Title", text: nonOptionalStringBinding($document.title))
                TextField("Author", text: nonOptionalStringBinding($document.author))
                TextField("Vendor", text: nonOptionalStringBinding($document.vendor))
                if let amount = document.amount { Text("Amount: $\(amount, specifier: "%.2f")") }
                if let year = document.year { Text("Year: \(year)") }
                if let d = document.invoiceDate { Text("Invoice: \(d.formatted(date: .numeric, time: .omitted))") }
            }
            Section("Tags") {
                HStack {
                    TextField("Add tag", text: $newTag)
                    Button("Add") {
                        let tag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !tag.isEmpty else { return }
                        if !document.tags.contains(tag) { document.tags.append(tag) }
                        newTag = ""
                    }
                }
                if !document.tags.isEmpty {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60), spacing: 6)], spacing: 6) {
                        ForEach(document.tags, id: \.self) { tag in
                            TagPill(title: tag) {
                                if let idx = document.tags.firstIndex(of: tag) {
                                    document.tags.remove(at: idx)
                                }
                            }
                        }
                    }
                }
                Button("Suggest Tags") {
                    let suggestions = TagSuggestionService.shared.suggestTags(text: document.contentTextSnippet ?? "")
                    for tag in suggestions where !document.tags.contains(tag) { document.tags.append(tag) }
                }
            }
            Section("Actions") {
                Button("Rotate Right 90°") { PDFOperations.rotate(urlBookmark: document.storedURLBookmark ?? document.originalURLBookmark, degrees: 90) }
                Button("Compress") { PDFOperations.compress(urlBookmark: document.storedURLBookmark ?? document.originalURLBookmark) }
                Button("Export as Images") { PDFOperations.exportImages(urlBookmark: document.storedURLBookmark ?? document.originalURLBookmark) }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - Sidebar helpers

private struct TagCloudView: View {
    var allTags: [String]
    var onSelect: (String) -> Void

    var body: some View {
        if allTags.isEmpty {
            ContentUnavailableView("No Tags", systemImage: "tag")
        } else {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60), spacing: 6)], spacing: 6) {
                ForEach(allTags, id: \.self) { tag in
                    TagPill(title: tag) { onSelect(tag) }
                }
            }
        }
    }
}

private struct TagPill: View {
    var title: String
    var onTap: (() -> Void)? = nil

    var body: some View {
        Text(title)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.regularMaterial, in: Capsule())
            .onTapGesture { onTap?() }
    }
}

// MARK: - Bindings utilities

private func nonOptionalStringBinding(_ source: Binding<String?>) -> Binding<String> {
    Binding<String>(
        get: { source.wrappedValue ?? "" },
        set: { newValue in
            if newValue.isEmpty {
                source.wrappedValue = nil
            } else {
                source.wrappedValue = newValue
            }
        }
    )
}

// MARK: - Menu Bar

struct QuickAddMenu: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                let panel = NSOpenPanel()
                panel.allowedContentTypes = [.pdf]
                panel.allowsMultipleSelection = true
                panel.begin { response in
                    if response == .OK {
                        Task {
                            do {
                                let records = try await PDFImportService.shared.importPDFs(urls: panel.urls)
                                for r in records { modelContext.insert(r) }
                            } catch { print("Quick Add failed: \(error)") }
                        }
                    }
                }
            } label: {
                Label("Quick Add PDFs…", systemImage: "plus")
            }

            Text("Drop PDFs here")
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                    let group = DispatchGroup()
                    var urls: [URL] = []
                    for p in providers {
                        group.enter()
                        p.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                            defer { group.leave() }
                            if let url = item as? URL { urls.append(url) }
                        }
                    }
                    group.notify(queue: .main) {
                        Task {
                            do {
                                let records = try await PDFImportService.shared.importPDFs(urls: urls)
                                for r in records { modelContext.insert(r) }
                            } catch { print("Drop import failed: \(error)") }
                        }
                    }
                    return true
                }
        }
        .padding(12)
        .frame(width: 280)
    }
}

// MARK: - PDFKit bridge

struct PDFKitView: NSViewRepresentable {
    var url: URL
    var bridge: PDFBridge

    func makeNSView(context: Context) -> PDFView {
        let view = PDFView()
        view.autoScales = true
        view.displayMode = .singlePageContinuous
        view.displayDirection = .vertical
        view.backgroundColor = .clear
        bridge.attach(view)
        view.document = PDFDocument(url: url)
        return view
    }

    func updateNSView(_ nsView: PDFView, context: Context) {
        if nsView.document?.documentURL != url { nsView.document = PDFDocument(url: url) }
    }
}
