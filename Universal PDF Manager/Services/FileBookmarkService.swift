//
//  FileBookmarkService.swift
//  Universal PDF Manager
//

import Foundation

final class FileBookmarkService {
    static let shared = FileBookmarkService()

    private init() {}

    func createBookmark(for url: URL) throws -> Data {
        return try url.bookmarkData(options: [.withSecurityScope], includingResourceValuesForKeys: nil, relativeTo: nil)
    }

    func url(from bookmark: Data?) -> URL? {
        guard let bookmark = bookmark else { return nil }
        var isStale = false
        do {
            let url = try URL(resolvingBookmarkData: bookmark, options: [.withSecurityScope], relativeTo: nil, bookmarkDataIsStale: &isStale)
            _ = url.startAccessingSecurityScopedResource()
            return url
        } catch {
            return nil
        }
    }
} 