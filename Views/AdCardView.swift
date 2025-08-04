import SwiftUI

struct AdCardView: View {
    let ad: AdResponse
    let onAdTapped: (() -> Void)?
    
    init(ad: AdResponse, onAdTapped: (() -> Void)? = nil) {
        self.ad = ad
        self.onAdTapped = onAdTapped
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with logo and company info
            headerSection
            
            // Background image
            backgroundImageSection
            
            // Content section
            contentSection
            
            // Action button
            actionButton
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16) // Match your app's corner radius
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2) // Match your card shadow
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            // Company logo
            AsyncImage(url: URL(string: fullLogoUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                logoPlaceholder
            }
            .frame(width: 32, height: 32)
            .cornerRadius(6)
            
            // Company info
            VStack(alignment: .leading, spacing: 2) {
                Text(ad.companyName)
                    .font(CustomFont.font(.medium, weight: .semibold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                
                Text("Sponsored")
                    .font(CustomFont.font(.small))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Ad badge
            Text("Ad")
                .font(CustomFont.font(.tiny, weight: .medium))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(12)
        }
    }
    
    // MARK: - Background Image Section
    private var backgroundImageSection: some View {
        AsyncImage(url: URL(string: fullBackgroundImageUrl)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } placeholder: {
            imagePlaceholder
        }
        .frame(height: 100)
        .clipped()
        .cornerRadius(12)
    }
    
    // MARK: - Content Section
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(ad.headline)
                .font(CustomFont.font(.medium, weight: .semibold))
                .foregroundColor(.black)
                .lineLimit(2)
            
            Text(ad.description)
                .font(CustomFont.font(.regular))
                .foregroundColor(.gray)
                .multilineTextAlignment(.leading)
                .lineLimit(3)
        }
    }
    
    // MARK: - Action Button
    private var actionButton: some View {
        Button(action: handleAdTap) {
            HStack {
                Text(ad.bookingButtonText)
                    .font(CustomFont.font(.medium, weight: .medium))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "arrow.right")
                    .foregroundColor(.white)
                    .font(CustomFont.font(.small))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color("Violet")) // Use your app's primary color
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Supporting Views
    private var logoPlaceholder: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Color.gray.opacity(0.3))
            .overlay(
                Image(systemName: "building.2")
                    .foregroundColor(.gray)
                    .font(CustomFont.font(.small))
            )
    }
    
    private var imagePlaceholder: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.gray.opacity(0.3))
            .overlay(
                Image(systemName: "photo")
                    .foregroundColor(.gray)
                    .font(CustomFont.font(.large))
            )
    }
    
    // MARK: - ✅ FIXED: URL Helpers for relative paths
    private var fullLogoUrl: String {
        if ad.logoUrl.starts(with: "/") {
            return "https://www.kayak.com\(ad.logoUrl)"
        }
        return ad.logoUrl
    }
    
    private var fullBackgroundImageUrl: String {
        if ad.backgroundImageUrl.starts(with: "/") {
            return "https://www.kayak.com\(ad.backgroundImageUrl)"
        }
        return ad.backgroundImageUrl
    }
    
    private var fullDeepLink: String {
        if ad.deepLink.starts(with: "/") {
            return "https://www.kayak.com\(ad.deepLink)"
        }
        return ad.deepLink
    }
    
    // MARK: - Actions
    private func handleAdTap() {
        // Track impression
        if !ad.impressionUrl.isEmpty {
            trackImpression()
        }
        
        // Open deep link
        openDeepLink()
        
        // Call custom handler if provided
        onAdTapped?()
    }
    
    private func trackImpression() {
        let fullImpressionUrl: String
        if ad.impressionUrl.starts(with: "/") {
            fullImpressionUrl = "https://www.kayak.com\(ad.impressionUrl)"
        } else {
            fullImpressionUrl = ad.impressionUrl
        }
        
        guard let url = URL(string: fullImpressionUrl) else {
            print("🎯 Invalid impression URL: \(fullImpressionUrl)")
            return
        }
        
        Task {
            do {
                let _ = try await URLSession.shared.data(from: url)
                print("🎯 Impression tracked for ad: \(ad.headline)")
            } catch {
                print("🎯 Failed to track impression: \(error)")
            }
        }
    }
    
    private func openDeepLink() {
        guard let url = URL(string: fullDeepLink) else {
            print("🎯 Invalid deep link URL: \(fullDeepLink)")
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url) { success in
                if success {
                    print("🎯 Successfully opened deep link: \(fullDeepLink)")
                } else {
                    print("🎯 Failed to open deep link: \(fullDeepLink)")
                }
            }
        } else {
            print("🎯 Cannot open URL: \(fullDeepLink)")
        }
    }
}
