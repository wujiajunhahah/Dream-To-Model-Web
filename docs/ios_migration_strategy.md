# DreamEcho iOS Migration Strategy

This document outlines the proposed approach for translating the DreamEcho Flask web experience into a native Swift-based iOS application that delivers a "liquid glass" aesthetic, real USDZ interactions, and full feature parity with the current product scope.

## 1. Target Platforms & Tooling
- **Primary OS**: iOS 16 and later (covers iPhone/iPad, aligns with RealityKit USDZ viewer requirements). If the roadmap targets iOS 17 or later, adjust APIs accordingly.
- **Language & Framework**: Swift 5.10+ (forward-compatible with Swift 6 betas), SwiftUI for all UI, Combine for reactive state, async/await networking.
- **3D/AR**: RealityKit + ARKit/QuickLook for USDZ rendering and immersive previews.
- **Build System**: Xcode 16 project with modular Swift packages for core features; shared code enables future visionOS/tvOS ports.

## 2. High-Level Architecture
1. **App Shell**: SwiftUI `TabView` hosting primary areas (Home, Dream Lab, Library, Profile). Wrap in a glassmorphism container (blurred backgrounds, frosted overlays) using `Material.regular` and custom shader effects.
2. **State Management**: ObservableObject view models per domain module (AuthViewModel, DreamCreationViewModel, DreamLibraryViewModel). Central `AppState` handles session and user profile.
3. **Networking Layer**: Abstraction over REST endpoints matching Flask routes. Use `URLSession` with async/await, typed response models via `Codable`. Support offline caching using `URLCache` and optional `CoreData` for persistent dream records.
4. **Authentication**: Leverage existing `/login` and `/register` endpoints. Store tokens/credentials securely in Keychain using `KeychainAccess` or custom wrapper.
5. **Dream Generation**:
   - Convert current multi-step Flask flow into a guided SwiftUI wizard (Description → AI Insights → Style & Blockchain → Checkout → Progress).
   - Poll backend job status; display progress using `TimelineView` animations matching particle effects with `Canvas`.
6. **Model Library & Detail**:
   - Grid/list views using `LazyVGrid` with glass cards and particle overlays.
   - Dream detail integrates `RealityView` (iOS 17) or `ARQuickLookPreviewController` for USDZ visualization.
7. **Notifications**: Integrate Push/Local notifications for job completion (requires backend endpoints). Provide in-app toast using `Overlay` system.
8. **Analytics & Logging**: Wrap in `OSLog` categories, optional SwiftLog backend streaming.

## 3. Feature Parity Mapping
| Web Feature | iOS Implementation |
|-------------|-------------------|
| Hero landing + marketing sections | SwiftUI scrollable hero with gradient glass backgrounds, `MatchedGeometryEffect` for animations |
| User authentication | Modal sheets using `Form` + Keychain storage |
| Dream creation form | Stepper flow with `NavigationStack`; attach AI previews |
| Real-time model progress | WebSocket or long-poll integration to `/progress` endpoint; display interactive timeline |
| 3D model viewer (fake placeholder in web) | RealityKit USDZ loader with pinch/zoom, AR placement via `ARQuickLook` |
| Model library | `LazyVGrid` with paging, search, filters |
| Profile & settings | `Form` sections for preferences with toggles bound to API |
| NFT trading CTA | Link-out to web marketplace or embed `SFSafariViewController` |

## 4. Liquid Glass Design System
- Use custom SwiftUI view modifiers to apply multi-layered blur, highlight borders, specular highlights (simulate "liquid glass").
- Define design tokens in `DesignSystem.swift`: `AppColor`, `Gradient`, `Shadow`, and `ShapeStyle` enumerations.
- Incorporate dynamic particle background using `Canvas` with timeline-driven particle emitters (replicate existing `particle.js` behavior).
- Include SF Symbols for iconography; ensure high contrast and accessible color usage.

## 5. USDZ Experience ("Make It Real")
- Wrap USDZ viewer in `RealityView` (iOS 17+) with fallback to `QuickLookPreview` for iOS 16.
- Provide progress indicators while loading models, allow download caching, and enable sharing/export.
- Implement AR placement with `ARQuickLookPreviewItem`; support object scaling and lighting adjustments.
- Validate USDZ assets using `ModelEntity.loadAsync(named:)` with error handling to replace fake placeholders.

## 6. Backend Integration Considerations
- Audit Flask routes (`/api/dreams`, `/api/models`, `/auth`) and ensure CORS/HTTPS support for mobile clients.
- Introduce OAuth token issuance or JWT to avoid session cookies.
- Expose WebSocket or SSE endpoint for model generation events to reduce polling latency.
- If migrating server to Swift (Vapor) is desired later, encapsulate endpoints behind an API gateway to allow gradual transition.

## 7. Testing & QA
- Unit tests with XCTest for view models and networking.
- Snapshot tests via `iOSSnapshotTestCase` for key glass UI screens.
- UI automation with XCTest UI; include AR viewer smoke tests using `simctl` to preload USDZ fixtures.
- Performance profiling (Instruments) for render loops and USDZ loading.

## 8. Project Timeline (Suggested)
1. **Week 0-1**: Finalize API contracts, create Swift package skeleton, and build design system.
2. **Week 2-3**: Implement Auth, Dream creation flow, and backend integration.
3. **Week 4**: Integrate USDZ viewer + particle backgrounds; add model library.
4. **Week 5**: QA, accessibility tuning, localization, prepare Xcode Cloud pipelines.
5. **Week 6**: Beta distribution via TestFlight, gather feedback, finalize App Store assets.

## 9. Deliverables
- `DreamEchoApp.xcodeproj` with modular Swift packages.
- Shared asset catalog (colors, gradients, imagery) aligned with web branding.
- Documentation for API integration, config, and Xcode Cloud pipeline.
- Automated tests + lint (SwiftLint or SwiftFormat) configuration.

## 10. Outstanding Items & Risks
- Need real API keys/secrets for DeepSeek/Tripo; mobile clients should request via backend proxy.
- Xcode Cloud requires Apple Developer account setup (Teams & certificates) – covered in deployment guide.
- Clarify NFT functionality on mobile (native vs deep link); blockchain signing may require WalletConnect integration.
- Confirm legal compliance for storing dreams/NFT data on-device.

