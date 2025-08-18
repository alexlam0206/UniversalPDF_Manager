//
//  PDFSecurityService.swift
//  Universal PDF Manager
//

import Foundation
import PDFKit

struct PDFSecurityOptions {
    var userPassword: String?
    var ownerPassword: String?
}

enum PDFSecurityService {
    static func encrypt(urlBookmark: Data?, options: PDFSecurityOptions) {
        guard let url = FileBookmarkService.shared.url(from: urlBookmark), let doc = PDFDocument(url: url) else { return }
        let tmp = url.deletingLastPathComponent().appendingPathComponent("__secured.pdf")
        var attrs: [PDFDocumentWriteOption : Any] = [:]
        if let user = options.userPassword { attrs[.userPasswordOption] = user }
        if let owner = options.ownerPassword { attrs[.ownerPasswordOption] = owner }
        if doc.write(to: tmp, withOptions: attrs) {
            try? FileManager.default.removeItem(at: url)
            try? FileManager.default.moveItem(at: tmp, to: url)
        }
    }

    static func decrypt(urlBookmark: Data?, password: String?) {
        guard let url = FileBookmarkService.shared.url(from: urlBookmark), let doc = PDFDocument(url: url) else { return }
        if let pwd = password { _ = doc.unlock(withPassword: pwd) }
        let tmp = url.deletingLastPathComponent().appendingPathComponent("__decrypted.pdf")
        if doc.write(to: tmp) {
            try? FileManager.default.removeItem(at: url)
            try? FileManager.default.moveItem(at: tmp, to: url)
        }
    }
} 