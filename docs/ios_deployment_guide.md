# DreamEcho iOS Deployment & CI/CD Guide

This guide explains how to version-control the new iOS code, push it to GitHub, and configure Xcode Cloud so builds remain green before turning on TestFlight distributions.

## 1. Prepare Git History
1. Ensure your local repo is clean (`git status`).
2. Add the new `ios/` directory and supporting docs:
   ```bash
   git add ios docs/ios_migration_strategy.md docs/ios_deployment_guide.md ios/README.md
   ```
3. Commit with a descriptive message:
   ```bash
   git commit -m "Add SwiftUI iOS scaffold and migration plan"
   ```
4. Set Git user/email if not configured:
   ```bash
   git config user.name "Your Name"
   git config user.email "you@example.com"
   ```
5. Push to GitHub (replace `origin` if you plan to publish to a different repository):
   ```bash
   git push origin main
   ```

> ℹ️ If you prefer to keep the iOS app in its own repository, run `git subtree split --prefix ios -b ios-app` and push that branch to a new GitHub repo.

## 2. Create the Xcode Project
1. Open Xcode 16 (or 15.4+) and create a new **App** project named `DreamEcho`.
2. Target iOS 16 as the minimum deployment target.
3. Delete the default SwiftUI files and drag all sources from `ios/DreamEchoApp/Sources` into the project (select “Copy items if needed”).
4. Add `DreamEchoApp/Package.swift` to the workspace if you prefer the Swift Package structure.
5. Import USDZ assets (e.g., `DreamStatue.usdz`) into your asset catalog.

## 3. Configure Xcode Cloud
1. In Xcode, choose **Product > Xcode Cloud > Create Workflow**.
2. Select your GitHub repository (requires linking Apple Developer account to GitHub).
3. Create two workflows:
   - **CI**: Trigger on every push to `main`/`develop`, run unit tests (`DreamEchoAppTests`).
   - **Beta**: Trigger on tags (e.g., `refs/tags/v*`); run tests, build for `Any iOS Device (arm64)`, archive, then upload to TestFlight.
4. Environment variables:
   - `API_BASE_URL` pointing to the Flask backend.
   - `DEEPSEEK_PROXY` or any secrets should be stored in Xcode Cloud secrets (never commit API keys).
5. Add additional actions:
   - SwiftLint/SwiftFormat (add as pre-build script).
   - `xcodebuild test -scheme DreamEcho -destination 'platform=iOS Simulator,name=iPhone 15 Pro'`.
6. Configure notifications so build failures alert the team via email or Slack.

## 4. Device & OS Targeting
- **Minimum**: iOS 16 (covers `Grid`, `ARQuickLook` usage).
- **Recommended**: QA on iOS 16, 17, and iPadOS 16+.
- For iOS 18 betas, create an additional Xcode Cloud workflow with the beta SDK once available.

## 5. Testing Checklist
- Unit tests (`DreamEchoAppTests`) validate core models.
- Add Snapshot/UI tests focusing on glass UI to catch visual regressions.
- Run AR/RealityKit smoke tests on physical devices or via TestFlight builds.
- Integrate post-generation integration tests using mocked backend responses (use `URLProtocol` stubs).

## 6. Distribution Steps
1. After Beta workflow greenlights, log in to App Store Connect and add release notes/screenshots.
2. Submit for TestFlight beta review; collect feedback from internal testers.
3. For public release, follow App Store Review Guidelines (privacy, NFT policy, etc.).

## 7. Outstanding Items
- Backend must expose token-based authentication to avoid session cookies on mobile.
- Implement real analytics/telemetry hooks before production (e.g., Firebase Analytics).
- Wallet integration for NFT minting is not yet implemented; plan a follow-up sprint.
