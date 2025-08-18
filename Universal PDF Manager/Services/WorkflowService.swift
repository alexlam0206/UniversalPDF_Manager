//
//  WorkflowService.swift
//  Universal PDF Manager
//

import Foundation

enum WorkflowStep {
    case compress
    case textWatermark(text: String)
    case addPageNumbers
    case encrypt(user: String?, owner: String?)
}

struct Workflow {
    var id: String
    var name: String
    var steps: [WorkflowStep]
}

enum WorkflowService {
    static func run(urlBookmark: Data?, workflow: Workflow) {
        for step in workflow.steps {
            switch step {
            case .compress:
                PDFOperations.compress(urlBookmark: urlBookmark)
            case .textWatermark(let text):
                PDFWatermarkService.applyTextWatermark(urlBookmark: urlBookmark, text: text)
            case .addPageNumbers:
                PDFNumberingService.addPageNumbers(urlBookmark: urlBookmark)
            case .encrypt(let user, let owner):
                PDFSecurityService.encrypt(urlBookmark: urlBookmark, options: PDFSecurityOptions(userPassword: user, ownerPassword: owner))
            }
        }
    }
} 