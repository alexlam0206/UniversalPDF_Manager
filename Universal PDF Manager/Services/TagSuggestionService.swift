//
//  TagSuggestionService.swift
//  Universal PDF Manager
//

import Foundation

final class TagSuggestionService {
    static let shared = TagSuggestionService()

    private init() {}

    func suggestTags(text: String) -> [String] {
        let lower = text.lowercased()
        var tags: Set<String> = []
        if lower.contains("invoice") || lower.contains("receipt") || lower.contains("amount") || lower.contains("total") {
            tags.insert("finance")
        }
        if lower.contains("university") || lower.contains("paper") || lower.contains("references") {
            tags.insert("school")
            tags.insert("research")
        }
        if lower.contains("boarding") || lower.contains("ticket") || lower.contains("flight") || lower.contains("airlines") {
            tags.insert("travel")
        }
        if lower.contains("tax") { tags.insert("tax") }
        if lower.contains("contract") { tags.insert("work") }
        return Array(tags)
    }
} 