import Foundation

// MARK: - Session Response Model
struct SessionResponse: Codable {
    let sid: String
}

// MARK: - ✅ FIXED: Ads Response Wrapper Model
struct AdsResponseWrapper: Codable {
    let inlineItems: [AdResponse]
}

// MARK: - ✅ UPDATED: Ad Response Model (matching actual API response)
struct AdResponse: Codable, Identifiable {
    let id = UUID() // For SwiftUI ForEach
    let rank: Int
    let backgroundImageUrl: String
    let impressionUrl: String
    let bookingButtonText: String
    let productType: String
    let headline: String
    let site: String
    let companyName: String
    let logoUrl: String
    let trackUrl: String?
    let deepLink: String
    let description: String
    
    // Custom CodingKeys to handle any naming differences
    enum CodingKeys: String, CodingKey {
        case rank
        case backgroundImageUrl
        case impressionUrl
        case bookingButtonText
        case productType
        case headline
        case site
        case companyName
        case logoUrl
        case trackUrl
        case deepLink
        case description
    }
}

// MARK: - Flight Search Request Models for Ads
struct FlightSearchRequestAds: Codable {
    let cabinClass: String
    let legs: [FlightLegModelAds]
    let passengers: [String]
}

struct FlightLegModelAds: Codable {
    let date: String
    let destinationAirport: String
    let originAirport: String
}

// MARK: - API Error Enum
enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case decodingError
    case encodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .serverError(let code):
            return "Server error with code: \(code)"
        case .decodingError:
            return "Failed to decode response"
        case .encodingError:
            return "Failed to encode request"
        }
    }
}
