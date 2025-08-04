import Foundation
import SwiftUI

class HotelAdsAPIService: ObservableObject {
    
    // MARK: - Constants
    private let baseURL = "https://devconnect.hoteldisc.com/api"
    private let bearerToken = "MuZgbVTZ6aYlhbb7jOPH"
    private let userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15"
    private let cookies = "Apache=j$SebA-AAABmHO7400-fc-EEvJRQ; cluster=4; kayak=KUOXMI8gRVz2CmcqxMp0; kayak.mc=AaiNcewfPXdXsDMrL7O2fE2X6Fh3qYbYdaFyuN3ziBNGPft-2kN9APMU7COMfiPtaEc-tYLqg4O72TvDuwJN3V1EUXsX_0s5XzZrW6c7KOSp; mst_ADIrkw=QQCEUOecQ09LmasgOvaaC_qkVOZ2u4T-QFEL4ObLMh-1plkJzAZ25sGULo6Rf-Ev0f21m2Dn51wh46-0mCqjLQ"
    
    // MARK: - Published Properties
    @Published var ads: [AdResponse] = []
    @Published var isLoadingAds = false
    @Published var adsErrorMessage: String?
    
    // MARK: - Session Creation
    func createSession(countryCode: String = "us", label: String = "flight.dev") async throws -> String {
        let urlString = "\(baseURL)/ads/session?countryCode=\(countryCode)&label=\(label)"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Set headers
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue(cookies, forHTTPHeaderField: "Cookie")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                print("🎯 Session creation failed with status: \(httpResponse.statusCode)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("🎯 Session response: \(responseString)")
                }
                throw APIError.serverError(httpResponse.statusCode)
            }
            
            let sessionResponse = try JSONDecoder().decode(SessionResponse.self, from: data)
            print("🎯 Session created successfully: \(sessionResponse.sid)")
            return sessionResponse.sid
            
        } catch let error as DecodingError {
            print("🎯 Session decoding error: \(error)")
            throw APIError.decodingError
        } catch {
            print("🎯 Session network error: \(error)")
            throw error
        }
    }
    
    // MARK: - ✅ FIXED: Fetch Ads with proper response parsing
    func fetchAds(
        sid: String,
        countryCode: String = "us",
        searchRequest: FlightSearchRequestAds
    ) async throws -> [AdResponse] {
        let urlString = "\(baseURL)/ads/flight/list?countryCode=\(countryCode)&_sid_=\(sid)"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Set headers exactly as in the working curl
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "content-type") // lowercase as in curl
        request.setValue(cookies, forHTTPHeaderField: "Cookie")
        
        // Encode request body
        do {
            let jsonData = try JSONEncoder().encode(searchRequest)
            request.httpBody = jsonData
            
            // Debug: Print request details
            print("🎯 Making ads request to: \(urlString)")
            print("🎯 Request body: \(String(data: jsonData, encoding: .utf8) ?? "Unable to decode")")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            // Debug: Print response
            let responseString = String(data: data, encoding: .utf8) ?? "Unable to decode response"
            print("🎯 Ads API response status: \(httpResponse.statusCode)")
            print("🎯 Ads API response body (first 500 chars): \(String(responseString.prefix(500)))")
            
            guard httpResponse.statusCode == 200 else {
                print("🎯 Ads API error - Status: \(httpResponse.statusCode)")
                print("🎯 Ads API error - Response: \(responseString)")
                throw APIError.serverError(httpResponse.statusCode)
            }
            
            // ✅ FIXED: Parse the wrapper object first, then extract inlineItems
            let adsWrapper = try JSONDecoder().decode(AdsResponseWrapper.self, from: data)
            print("🎯 Successfully decoded \(adsWrapper.inlineItems.count) ads")
            
            // Debug: Print first ad details
            if let firstAd = adsWrapper.inlineItems.first {
                print("🎯 First ad: \(firstAd.headline) by \(firstAd.companyName)")
            }
            
            return adsWrapper.inlineItems
            
        } catch let error as EncodingError {
            print("🎯 Ads encoding error: \(error)")
            throw APIError.encodingError
        } catch let error as DecodingError {
            print("🎯 Ads decoding error: \(error)")
            print("🎯 Decoding error details: \(error.localizedDescription)")
            throw APIError.decodingError
        } catch {
            print("🎯 Ads network error: \(error)")
            throw error
        }
    }
    
    // MARK: - Combined Search Method
    @MainActor
    func searchFlightAds(
        originAirport: String,
        destinationAirport: String,
        date: String,
        cabinClass: String = "economy",
        passengers: [String] = ["adult"],
        countryCode: String = "us"
    ) async {
        isLoadingAds = true
        adsErrorMessage = nil
        ads = []
        
        do {
            print("🎯 Creating ads session...")
            let sid = try await createSession(countryCode: countryCode)
            print("🎯 Ads session created with SID: \(sid)")
            
            let searchRequest = FlightSearchRequestAds(
                cabinClass: cabinClass,
                legs: [
                    FlightLegModelAds(
                        date: date,
                        destinationAirport: destinationAirport,
                        originAirport: originAirport
                    )
                ],
                passengers: passengers
            )
            
            print("🎯 Fetching ads with search request...")
            print("🎯 Search params: \(originAirport) → \(destinationAirport), \(date), \(cabinClass), \(passengers.count) passengers")
            
            let fetchedAds = try await fetchAds(
                sid: sid,
                countryCode: countryCode,
                searchRequest: searchRequest
            )
            
            print("🎯 Successfully fetched \(fetchedAds.count) ads")
            self.ads = fetchedAds
            
            // Debug: Log all ad headlines
            for (index, ad) in fetchedAds.enumerated() {
                print("🎯 Ad \(index + 1): \(ad.headline) - \(ad.companyName)")
            }
            
        } catch {
            print("🎯 Error in searchFlightAds: \(error)")
            if let apiError = error as? APIError {
                self.adsErrorMessage = apiError.localizedDescription
            } else {
                self.adsErrorMessage = error.localizedDescription
            }
        }
        
        isLoadingAds = false
    }
    
    // MARK: - Track Impression
    func trackImpression(impressionUrl: String) {
        // ✅ FIXED: Handle relative URLs by prepending base domain
        let fullImpressionUrl: String
        if impressionUrl.starts(with: "/") {
            fullImpressionUrl = "https://www.kayak.com\(impressionUrl)"
        } else {
            fullImpressionUrl = impressionUrl
        }
        
        guard let url = URL(string: fullImpressionUrl) else {
            print("🎯 Invalid impression URL: \(fullImpressionUrl)")
            return
        }
        
        Task {
            do {
                let _ = try await URLSession.shared.data(from: url)
                print("🎯 Impression tracked successfully: \(fullImpressionUrl)")
            } catch {
                print("🎯 Failed to track impression: \(error)")
            }
        }
    }
}
