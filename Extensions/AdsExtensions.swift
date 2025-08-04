import Foundation
import SwiftUI

// MARK: - Date Extensions
extension Date {
    func toAPIDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: self)
    }
    
    func toDisplayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
}

// MARK: - String Extensions
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    var isValidAirportCode: Bool {
        return self.count == 3 && self.allSatisfy { $0.isLetter }
    }
    
    func formattedAirportCode() -> String {
        return self.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Color Extensions
extension Color {
    static let customBackground = Color(.systemBackground)
    static let customSecondaryBackground = Color(.secondarySystemBackground)
    static let customTertiaryBackground = Color(.tertiarySystemBackground)
    
    // Custom app colors
    static let primaryBlue = Color(red: 0.0, green: 0.48, blue: 1.0)
    static let successGreen = Color(red: 0.2, green: 0.78, blue: 0.35)
    static let warningOrange = Color(red: 1.0, green: 0.58, blue: 0.0)
    static let errorRed = Color(red: 1.0, green: 0.23, blue: 0.19)
}

// MARK: - View Extensions
extension View {
    func cardStyle() -> some View {
        self
            .background(Color.customBackground)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    func primaryButtonStyle() -> some View {
        self
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.primaryBlue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .fontWeight(.semibold)
    }
    
    func secondaryButtonStyle() -> some View {
        self
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.primaryBlue, lineWidth: 1)
            )
            .foregroundColor(.primaryBlue)
            .cornerRadius(10)
            .fontWeight(.medium)
    }
}

// MARK: - Array Extensions
extension Array where Element == String {
    func toPassengerArray(count: Int) -> [String] {
        return Array(repeating: "adult", count: Swift.max(1, count))
    }
}

// MARK: - URLRequest Extensions
extension URLRequest {
    mutating func setDefaultHeaders() {
        let config = APIConfiguration.shared
        let headers = config.getDefaultHeaders()
        
        for (key, value) in headers {
            self.setValue(value, forHTTPHeaderField: key)
        }
    }
}

// MARK: - URL Extensions
extension URL {
    static func buildAPIURL(endpoint: String, queryItems: [URLQueryItem] = []) -> URL? {
        let baseURL = APIConfiguration.shared.baseURL
        var components = URLComponents(string: "\(baseURL)/\(endpoint)")
        
        if !queryItems.isEmpty {
            components?.queryItems = queryItems
        }
        
        return components?.url
    }
}

// MARK: - Binding Extensions
extension Binding {
    func onValueChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}

// MARK: - AdResponse Extensions
extension AdResponse {
    var isValidAd: Bool {
        return !headline.isEmpty &&
               !deepLink.isEmpty &&
               !companyName.isEmpty
    }
    
    var formattedProductType: String {
        return productType.replacingOccurrences(of: "_", with: " ").capitalized
    }
    
    var hasValidImageURL: Bool {
        return URL(string: backgroundImageUrl) != nil
    }
    
    var hasValidLogoURL: Bool {
        return URL(string: logoUrl) != nil
    }
}
