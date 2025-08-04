# Ads Integration Guide

## Overview

This document explains how to integrate and display ads within your flight search results. The implementation allows you to mix sponsored airline ads with organic flight results to create a native advertising experience.

## Architecture

The ads system consists of several key components:

- **AdsService**: Handles fetching and managing ad data
- **AdResponse**: Data model representing individual ads
- **AdCardView**: UI component for displaying ads
- **Mixed Content Integration**: Logic for inserting ads between flight results

## Setup

### 1. Data Models

First, ensure you have the necessary data models for ads:

```swift
struct AdResponse {
    let rank: Int
    let backgroundImageUrl: String
    let bookingButtonText: String
    let impressionUrl: String
    let productType: String
    let trackUrl: String?
    let headline: String
    let site: String
    let companyName: String
    let logoUrl: String
    let deepLink: String
    let description: String
}
```

### 2. Ads Service

Create an `AdsService` class to handle ad loading:

```swift
@MainActor
class AdsService: ObservableObject {
    @Published var ads: [AdResponse] = []
    @Published var isLoading = false
    @Published var adsErrorMessage: String?
    
    func loadAds(for searchParameters: SearchParameters) {
        // Implementation for loading ads from your API
        // Handle the JSON response structure shown in paste.txt
    }
}
```

### 3. Integration in ViewModel

Add ads service to your result view model:

```swift
class ResultViewModel: ObservableObject {
    let adsService = AdsService()
    
    func loadAdsForSearch(searchParameters: SearchParameters) {
        adsService.loadAds(for: searchParameters)
    }
}
```

## Implementation

### 1. Content Type Enum

Create an enum to handle mixed content (flights + ads):

```swift
enum ContentType {
    case flight(FlightResult)
    case ad(AdResponse)
}
```

### 2. Mixed Content Generation

Implement logic to mix ads with flight results:

```swift
private func generateMixedContent() -> [ContentType] {
    var mixedContent: [ContentType] = []
    let flights = viewModel.flightResults
    let ads = viewModel.adsService.ads
    
    // Add all flights first
    for flight in flights {
        mixedContent.append(.flight(flight))
    }
    
    // Insert ads at strategic positions (every 3-4 flights)
    var adIndex = 0
    let positions = [2, 6, 10, 15, 20, 25, 30] // Customize these positions
    
    for position in positions {
        if position < mixedContent.count && adIndex < ads.count {
            mixedContent.insert(.ad(ads[adIndex]), at: position + adIndex)
            adIndex += 1
        } else if adIndex >= ads.count {
            break
        }
    }
    
    return mixedContent
}
```

### 3. Display Mixed Content

In your view, handle both content types:

```swift
ForEach(Array(generateMixedContent().enumerated()), id: \.offset) { index, content in
    switch content {
    case .flight(let flight):
        Button {
            // Handle flight selection
        } label: {
            ResultCard(flight: flight, isRoundTrip: searchParameters.isRoundTrip)
        }
        
    case .ad(let ad):
        AdCardView(ad: ad) {
            // Handle ad tap
            print("🎯 Ad tapped: \(ad.headline)")
        }
    }
}
```

## Ad Card UI Component

Create a visually appealing ad card that matches your app's design:

```swift
struct AdCardView: View {
    let ad: AdResponse
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Background image
            AsyncImage(url: URL(string: ad.backgroundImageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(height: 120)
            .clipped()
            
            // Content overlay
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    AsyncImage(url: URL(string: ad.logoUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                    }
                    .frame(width: 24, height: 24)
                    
                    Text(ad.site)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text("Ad")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                }
                
                Text(ad.headline)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(ad.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                Button(ad.bookingButtonText) {
                    onTap()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
```

## API Integration

### Expected JSON Structure

Your ads API should return data in this format:

```json
{
    "inlineItems": [
        {
            "rank": 1,
            "backgroundImageUrl": "/path/to/image.jpg",
            "bookingButtonText": "View Deal",
            "impressionUrl": "/impression/url",
            "productType": "flight",
            "headline": "Travel with Europe's best",
            "site": "Turkish Airlines",
            "companyName": "TÜRK HAVA YOLLARI ANONİM ORTAKLIĞI",
            "logoUrl": "/path/to/logo.svg",
            "deepLink": "/booking/url",
            "description": "Comfortable seats with awarded dining service"
        }
    ]
}
```

### API Call Example

```swift
func loadAds(for searchParameters: SearchParameters) async {
    isLoading = true
    adsErrorMessage = nil
    
    do {
        let url = buildAdsURL(for: searchParameters)
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(AdsResponse.self, from: data)
        
        await MainActor.run {
            self.ads = response.inlineItems
            self.isLoading = false
        }
    } catch {
        await MainActor.run {
            self.adsErrorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
}
```

## Best Practices

### 1. Ad Placement Strategy

- **Position 2**: After 2 organic results (early visibility)
- **Position 6**: Mid-scroll engagement
- **Positions 10, 15, 20+**: Maintain engagement during longer browsing

### 2. User Experience

- **Native Design**: Ads should match your app's visual style
- **Clear Labeling**: Always mark sponsored content with "Ad" or "Sponsored"
- **Non-Intrusive**: Don't overwhelm users with too many ads
- **Relevant Content**: Ensure ads match user search intent

### 3. Performance

- **Parallel Loading**: Load ads simultaneously with flight results
- **Error Handling**: Don't let ad failures break the main experience
- **Caching**: Cache ad responses to improve performance

### 4. Analytics & Tracking

```swift
// Track ad impressions
func trackAdImpression(ad: AdResponse) {
    if let impressionURL = URL(string: ad.impressionUrl) {
        URLSession.shared.dataTask(with: impressionURL).resume()
    }
}

// Track ad clicks
func trackAdClick(ad: AdResponse) {
    if let trackURL = URL(string: ad.trackUrl ?? "") {
        URLSession.shared.dataTask(with: trackURL).resume()
    }
    
    // Open deep link
    if let deepLinkURL = URL(string: ad.deepLink) {
        UIApplication.shared.open(deepLinkURL)
    }
}
```

## Debugging

Add debug logging to monitor ad integration:

```swift
// In your view model
.onReceive(viewModel.adsService.$ads) { ads in
    print("🎯 ResultView received \(ads.count) ads")
    for (index, ad) in ads.enumerated() {
        print("   Ad \(index + 1): \(ad.headline) - \(ad.companyName)")
    }
}

// In mixed content generation
print("🎯 Generated mixed content: \(flights.count) flights + \(adIndex) ads = \(mixedContent.count) total items")
```

## Error Handling

```swift
// Handle ads errors gracefully
.onReceive(viewModel.adsService.$adsErrorMessage) { error in
    if let error = error {
        print("🎯 Ads loading error (non-blocking): \(error)")
        // Don't show error to user - ads are supplementary
    }
}
```

## Testing

### Unit Tests

```swift
func testAdPlacement() {
    // Test that ads are placed at correct positions
    let mixedContent = generateMixedContent()
    // Assert ad positions are correct
}

func testAdService() {
    // Test ads service loading
    let service = AdsService()
    // Test loading, error handling, etc.
}
```

### Manual Testing Checklist

- [ ] Ads load without blocking flight results
- [ ] Ad positions look natural in the list
- [ ] Ad taps open correct deep links
- [ ] Ad design matches app style
- [ ] Error states are handled gracefully
- [ ] Performance remains smooth with ads

## Monetization Considerations

1. **Revenue Tracking**: Implement proper attribution for ad clicks and conversions
2. **A/B Testing**: Test different ad positions and frequencies
3. **User Feedback**: Monitor user engagement and satisfaction
4. **Compliance**: Ensure ads meet platform guidelines and regulations

## Support

For questions about ads integration:

1. Check debug logs for error messages
2. Verify API endpoints and data formats
3. Test with different search parameters
4. Monitor network requests in development
