import Foundation
import SwiftUI

// MARK: - API Configuration
struct APIConfiguration {
    static let shared = APIConfiguration()
    
    let baseURL = "https://devconnect.hoteldisc.com/api"
    let bearerToken = "MuZgbVTZ6aYlhbb7jOPH"
    let userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15"
    let cookies = "Apache=j$SebA-AAABmHO7400-fc-EEvJRQ; cluster=4; kayak=KUOXMI8gRVz2CmcqxMp0; kayak.mc=AaiNcewfPXdXsDMrL7O2fE2X6Fh3qYbYdaFyuN3ziBNGPft-2kN9APMU7COMfiPtaEc-tYLqg4O72TvDuwJN3V1EUXsX_0s5XzZrW6c7KOSp; mst_ADIrkw=QQCEUOecQ09LmasgOvaaC_qkVOZ2u4T-QFEL4ObLMh-1plkJzAZ25sGULo6Rf-Ev0f21m2Dn51wh46-0mCqjLQ"
    
    private init() {}
    
    // MARK: - Request Headers
    func getDefaultHeaders() -> [String: String] {
        return [
            "Accept": "application/json",
            "Authorization": "Bearer \(bearerToken)",
            "User-Agent": userAgent,
            "Content-Type": "application/json",
            "Cookie": cookies
        ]
    }
}

// MARK: - API Constants
struct APIConstants {
    // Base Configuration
    static let baseURL = "https://devconnect.hoteldisc.com/api"
    static let bearerToken = "MuZgbVTZ6aYlhbb7jOPH"
    static let defaultCountryCode = "us"
    static let defaultLabel = "flight.dev"
    
    // Endpoints
    struct Endpoints {
        static let session = "session"
        static let flightAds = "ads/flight/list"
    }
    
    // Headers
    struct Headers {
        static let accept = "application/json"
        static let contentType = "application/json"
        static let userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15"
        static let cookies = "Apache=j$SebA-AAABmHO7400-fc-EEvJRQ; cluster=4; kayak=KUOXMI8gRVz2CmcqxMp0; kayak.mc=AaiNcewfPXdXsDMrL7O2fE2X6Fh3qYbYdaFyuN3ziBNGPft-2kN9APMU7COMfiPtaEc-tYLqg4O72TvDuwJN3V1EUXsX_0s5XzZrW6c7KOSp; mst_ADIrkw=QQCEUOecQ09LmasgOvaaC_qkVOZ2u4T-QFEL4ObLMh-1plkJzAZ25sGULo6Rf-Ev0f21m2Dn51wh46-0mCqjLQ"
    }
    
    // Timeout Configuration
    static let requestTimeout: TimeInterval = 30.0
    static let resourceTimeout: TimeInterval = 60.0
}

// MARK: - UI Constants
struct UIConstants {
    // Spacing
    static let smallSpacing: CGFloat = 8
    static let mediumSpacing: CGFloat = 16
    static let largeSpacing: CGFloat = 24
    static let extraLargeSpacing: CGFloat = 32
    
    // Corner Radius
    static let smallCornerRadius: CGFloat = 8
    static let mediumCornerRadius: CGFloat = 12
    static let largeCornerRadius: CGFloat = 16
    
    // Shadow
    static let shadowRadius: CGFloat = 4
    static let shadowOpacity: Double = 0.1
    static let shadowOffset: CGSize = CGSize(width: 0, height: 2)
    
    // Animation
    static let defaultAnimationDuration: Double = 0.3
    static let fastAnimationDuration: Double = 0.15
    static let slowAnimationDuration: Double = 0.5
    
    // Image Sizes
    static let logoSize: CGSize = CGSize(width: 40, height: 40)
    static let backgroundImageHeight: CGFloat = 120
    
    // Button Heights
    static let primaryButtonHeight: CGFloat = 48
    static let secondaryButtonHeight: CGFloat = 44
}

// MARK: - Flight Constants
struct FlightConstants {
    // Cabin Classes
    static let cabinClasses = [
        "economy",
        "premium_economy",
        "business",
        "first"
    ]
    
    // Passenger Types
    static let passengerTypes = [
        "adult",
        "child",
        "infant"
    ]
    
    // Popular Airport Codes
    static let popularAirports = [
        "NYC": "New York City",
        "LAX": "Los Angeles",
        "DXB": "Dubai",
        "LHR": "London Heathrow",
        "CDG": "Paris Charles de Gaulle",
        "NRT": "Tokyo Narita",
        "SIN": "Singapore",
        "HKG": "Hong Kong",
        "SYD": "Sydney",
        "MEL": "Melbourne"
    ]
    
    // Limits
    static let maxPassengers = 9
    static let minPassengers = 1
    static let maxDaysInFuture = 365
    static let airportCodeLength = 3
}

// MARK: - Error Messages
struct ErrorMessages {
    static let networkError = "Network connection failed. Please check your internet connection."
    static let invalidResponse = "Invalid response from server."
    static let decodingError = "Failed to process server response."
    static let encodingError = "Failed to prepare request data."
    static let invalidURL = "Invalid URL configuration."
    static let sessionCreationFailed = "Failed to create session. Please try again."
    static let noAdsFound = "No flight deals found for your search criteria."
    static let invalidAirportCode = "Please enter a valid 3-letter airport code."
    static let invalidDate = "Please select a valid departure date."
    static let generalError = "Something went wrong. Please try again."
}

// MARK: - Success Messages
struct SuccessMessages {
    static let sessionCreated = "Session created successfully"
    static let adsLoaded = "Flight deals loaded successfully"
    static let impressionTracked = "Impression tracked"
    static let linkOpened = "Opening booking page"
}

// MARK: - App Configuration
struct AppConfiguration {
    static let appName = "Flight Ads"
    static let version = "1.0.0"
    static let bundleIdentifier = "com.flightads.app"
    
    // Feature Flags
    static let enableNetworkMonitoring = true
    static let enableAnalytics = false
    static let enableDeepLinking = true
    static let enableImpressionTracking = true
    
    // Debug Settings
    #if DEBUG
    static let enableLogging = true
    static let enableDetailedErrors = true
    #else
    static let enableLogging = false
    static let enableDetailedErrors = false
    #endif
}

// MARK: - Validation Rules
struct ValidationRules {
    static let airportCodeRegex = "^[A-Z]{3}$"
    static let minSearchLength = 3
    static let maxDescriptionLength = 200
    static let maxHeadlineLength = 100
    
    static func isValidAirportCode(_ code: String) -> Bool {
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        return trimmed.count == FlightConstants.airportCodeLength &&
               trimmed.allSatisfy { $0.isLetter }
    }
    
    static func isValidDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let today = Date()
        let maxDate = calendar.date(byAdding: .day,
                                   value: FlightConstants.maxDaysInFuture,
                                   to: today) ?? today
        
        return date >= calendar.startOfDay(for: today) && date <= maxDate
    }
    
    static func isValidPassengerCount(_ count: Int) -> Bool {
        return count >= FlightConstants.minPassengers &&
               count <= FlightConstants.maxPassengers
    }
}
