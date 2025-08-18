//
//  Item.swift
//  Universal PDF Manager
//
//  Created by Alex Lam on 18/8/2025.
//

import Foundation
import SwiftData

@available(macOS 14.0, *)
@Model
final class PDFDocumentRecord {
    @Attribute(.unique) var id: String
    var fileName: String
    var originalURLBookmark: Data?
    var storedURLBookmark: Data?
    var fileSizeBytes: Int64
    var pageCount: Int
    var createdAt: Date
    var updatedAt: Date
    var detectedLanguageCodes: [String]
    var ocrPerformed: Bool
    var ocrLanguages: [String]
    var title: String?
    var author: String?
    var year: Int?
    var vendor: String?
    var invoiceDate: Date?
    var amount: Double?
    var passenger: String?
    var airline: String?
    var flightDate: Date?
    var contentTextSnippet: String?
    var tags: [String]
    var userNotes: String?
    var spotlightIndexed: Bool

    init(
        id: String = UUID().uuidString,
        fileName: String,
        originalURLBookmark: Data? = nil,
        storedURLBookmark: Data? = nil,
        fileSizeBytes: Int64 = 0,
        pageCount: Int = 0,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        detectedLanguageCodes: [String] = [],
        ocrPerformed: Bool = false,
        ocrLanguages: [String] = [],
        title: String? = nil,
        author: String? = nil,
        year: Int? = nil,
        vendor: String? = nil,
        invoiceDate: Date? = nil,
        amount: Double? = nil,
        passenger: String? = nil,
        airline: String? = nil,
        flightDate: Date? = nil,
        contentTextSnippet: String? = nil,
        tags: [String] = [],
        userNotes: String? = nil,
        spotlightIndexed: Bool = false
    ) {
        self.id = id
        self.fileName = fileName
        self.originalURLBookmark = originalURLBookmark
        self.storedURLBookmark = storedURLBookmark
        self.fileSizeBytes = fileSizeBytes
        self.pageCount = pageCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.detectedLanguageCodes = detectedLanguageCodes
        self.ocrPerformed = ocrPerformed
        self.ocrLanguages = ocrLanguages
        self.title = title
        self.author = author
        self.year = year
        self.vendor = vendor
        self.invoiceDate = invoiceDate
        self.amount = amount
        self.passenger = passenger
        self.airline = airline
        self.flightDate = flightDate
        self.contentTextSnippet = contentTextSnippet
        self.tags = tags
        self.userNotes = userNotes
        self.spotlightIndexed = spotlightIndexed
    }
}

@available(macOS 14.0, *)
extension PDFDocumentRecord: @unchecked Sendable {}
