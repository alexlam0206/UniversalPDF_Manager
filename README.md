# Universal PDF Manager (macOS)

A native macOS PDF manager and editor built with Swift, SwiftUI, AppKit, PDFKit, and Vision.

> Status: Early preview. The app may not run very well across machines yet (expect rough edges and bugs). Contributions and forks are very welcome — please open issues, submit PRs, or fork to improve it.

`The Universal PDF Manager is under MIT License. `

## Requirements
- macOS 15.0+
- Xcode 16 (or a compatible recent version)

## Feature Highlights
- Smart import and naming: OCR + text parsing for invoices (vendor/date/amount), academic papers (title/author/year), and tickets (airline/passenger/date)
- Tagging & filing suggestions: drag-and-drop oriented workflows
- PDF editing: merge, split, rotate, reorder (via thumbnail drag), export images, basic compression
- Annotation & markup: highlight, simple redaction (solid rectangle cover)
- OCR: built-in Vision OCR with multiple languages; OCR → RTF
- Search: in-window search with highlights; sidebar tabs for Thumbnails / Outline / Annotations
- UI/UX: Liquid Glass (ultraThin on macOS 26), dark/light themes, menu bar Quick Add
- Storage: SwiftData (SQLite), app sandbox with security-scoped bookmarks

## Project Structure (key parts)
- `ContentView.swift`: main 3-column layout, toolbar, import, search, tool wiring
- `Views/SidebarTabsView.swift`: tabs for Thumbnails / Outline / Annotations
- `Views/SavingPDFThumbnailView.swift`: auto-save after thumbnail drag reordering
- `Services/PDFOperations.swift`: rotate, export images, (basic) compress
- `Services/PDFWatermarkService.swift`, `PDFNumberingService.swift`, `PDFSecurityService.swift`, `PDFRedactionService.swift`
- `Services/ImagesToPDFService.swift`: images → PDF
- `Services/WorkflowService.swift`: simple workflows (compress/watermark/page numbers/encrypt)
- `Services/OCREngine.swift`, `OCRToWordExporter.swift`, `PDFTextExtractor.swift`, etc.

## Package the .app (Xcode GUI)
1. Open the project → select Scheme: Universal PDF Manager
2. Set configuration to "Release"
3. Product → Archive
4. In Organizer: Distribute App → Copy App (or Developer ID / Notarization as needed) → export `.app`

Release suggestion
1) Rebuild via CLI above → produce `Universal_PDF_Manager.zip`
2) Create a GitHub Release and attach the zip

## Usage
- Import: drag PDFs into the sidebar or use the menu bar Quick Add
- Preview: main PDF view + sidebar tabs (thumbnails/outline/annotations)
- Tools (toolbar → Tools): export images, compress, add page numbers, watermark, encrypt/decrypt, images→PDF, workflow
- Search: toolbar Search or Cmd-F panel
- Settings: App → Settings (OCR languages, Liquid Glass auto, rename pattern, etc.)

## Notes
- Compression: PDFKit lacks advanced compression APIs; current implementation is basic. Future work may add Quartz Filter options and size estimation
- Redaction: implemented via solid rectangles. For true content removal, consider re-rendering to a new PDF
- Security: sandbox + user-selected files via security-scoped bookmarks

## Roadmap (short-term)
- Thumbnail context menu bulk actions (delete/rotate/extract/export pages)
- Compression options panel (High/Medium/Low with size estimation)
- Watermark/Page Number config panels (font, position, opacity, page ranges)

## Contributing
Bugs, ideas, and improvements are welcome! Please open an issue, submit a PR, or fork the repo. If you encounter build/runtime issues on your setup, include your macOS/Xcode versions and steps to reproduce.

## License
MIT 
