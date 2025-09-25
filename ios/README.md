# DreamEcho iOS Prototype

This directory contains a SwiftUI scaffolding for the DreamEcho native app. Bring these sources into a new Xcode project (`File > New > Project > App`) targeting iOS 16+. After the project is created, replace the generated Swift files with the ones inside `DreamEchoApp/Sources` and add any USDZ assets to the asset catalog.

## Highlights
- `DreamEchoApp.swift`: Entry point using `RootTabView` with Home, Dream Lab, Library, Profile tabs.
- `DesignSystem/DesignSystem.swift`: Defines colors, gradients, glass modifiers, and button styles that mirror the web "liquid glass" aesthetic.
- `Views/Screens`: SwiftUI screens for Home, Dream creation flow, library, and profile.
- `Views/Components/USDZViewer.swift`: RealityKit + QuickLook integration to load USDZ files and provide an AR preview.
- `Networking/APIClient.swift`: Async/await REST client prepared for the current Flask endpoints (replace `baseURL` with your deployment URL).
- `ViewModels/AppState.swift`: Central observable state that pulls session data and dream collections.

## Next Steps
1. Create an Xcode project and import these sources.
2. Add a `DreamStatue.usdz` placeholder (or your actual models) into the bundle.
3. Wire the `APIClient` to the real backend endpoints and authentication (JWT recommended).
4. Implement persistent storage (Core Data or Realm) for offline dream access.
5. Connect push notifications for model-generation completion alerts.

## Configuration
- Update `Resources/Info.plist` with production `API_BASE_URL` and optional `API_EVENTS_URL` for SSE/WebSocket endpoints.
- Alternatively, provide `API_BASE_URL` via environment variable for Xcode Cloud or CI pipelines.
- Tokens are persisted securely using the system Keychain; reset by calling `AuthService.logout()` or deleting the app.
