//
//  TermsService.swift
//  Forday
//
//  Created by Subeen on 2/7/26.
//

import Foundation

final class TermsService {

    // MARK: - Local JSON Models

    private struct TermsJSON: Codable {
        let termsOfService: TermsContent
        let privacyPolicy: TermsContent
    }

    private struct TermsContent: Codable {
        let title: String
        let description: String?
        let version: String
        let sections: [Section]
        let serviceInfo: ServiceInfo
    }

    private struct Section: Codable {
        let sectionNo: Int
        let sectionTitle: String
        let articles: [Article]
    }

    private struct Article: Codable {
        let articleId: Int
        let clauseNo: Int?
        let content: String
        let items: [Item]
    }

    private struct Item: Codable {
        let itemId: Int
        let itemNo: Int
        let content: String
    }

    private struct ServiceInfo: Codable {
        let title: String?
        let description: String?
        let serviceName: String
        let companyName: String
        let email: String
        let representative: String
        let contactNumber: String
    }

    // MARK: - 서비스 이용약관 조회

    func fetchTermsOfService() async throws -> String {
        let terms = try loadTermsFromJSON()
        return formatTermsContent(terms.termsOfService)
    }

    // MARK: - 개인정보 처리방침 조회

    func fetchPrivacyPolicy() async throws -> String {
        let terms = try loadTermsFromJSON()
        return formatTermsContent(terms.privacyPolicy)
    }

    // MARK: - Private Methods

    private func loadTermsFromJSON() throws -> TermsJSON {
        guard let url = Bundle.main.url(forResource: "Terms", withExtension: "json") else {
            throw TermsError.fileNotFound
        }

        let data = try Data(contentsOf: url)
        let terms = try JSONDecoder().decode(TermsJSON.self, from: data)
        return terms
    }

    private func formatTermsContent(_ content: TermsContent) -> String {
        var result = ""

        // Title and description
        if let description = content.description {
            result += "\(description)\n\n"
        }

        // Sections
        for section in content.sections {
            result += "제\(section.sectionNo)조 (\(section.sectionTitle))\n"

            for article in section.articles {
                if let clauseNo = article.clauseNo {
                    result += "\(clauseNo). \(article.content)\n"
                } else {
                    result += "\(article.content)\n"
                }

                for item in article.items {
                    result += "   \(item.itemNo)) \(item.content)\n"
                }
            }

            result += "\n"
        }

        // Service Info (부칙)
        if let title = content.serviceInfo.title {
            result += "[\(title)]\n"
        }
        if let description = content.serviceInfo.description {
            result += "\(description)\n"
        }

        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - TermsError

enum TermsError: Error, LocalizedError {
    case fileNotFound

    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "약관 파일을 찾을 수 없습니다."
        }
    }
}
