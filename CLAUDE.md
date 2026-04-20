# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Home Monitoring now contains two codepaths:

- `javascript_app/` is the primary runnable app in this repository. It is a Node.js and Express rewrite of the mock monitoring dashboard and JSON API that previously lived in Flask.
- `home-monitoring/` is the original iOS app (Swift 6, iOS 17+) that reads temperature and pressure data from Estimote BLE beacons.

## Build & Run

### JavaScript App

- **Install:** `cd javascript_app && npm install`
- **Run:** `npm start`
- **Test:** `npm test`
- **Format:** `npm run format`

### Legacy iOS App

This is a native Xcode project with no package managers (no CocoaPods, Carthage, or SPM). The EstimoteSDK.framework is manually embedded.

- **Open:** `home-monitoring.xcodeproj` in Xcode 15+
- **Build/Run:** Cmd+R (requires a physical iPhone with iOS 17+)
- **Testing requires:** a physical Estimote beacon device

### Required Setup Before Building

1. Set beacon identifier in `home-monitoring/BeaconManager.swift` (the `monitoringDeviceIdentifier` property)
2. Set Estimote Cloud credentials in `home-monitoring/AppDelegate.swift` via `ESTConfig.setupAppID(_:andAppToken:)`

## Architecture

### JavaScript App

- **`javascript_app/src/server.js`** — Node entrypoint that starts the Express server
- **`javascript_app/src/app.js`** — Express app factory with route registration and JSON error handling
- **`javascript_app/src/models.js`** — Mock sensor and connection-state data helpers
- **`javascript_app/src/utils.js`** — Payload parsing and unit conversion helpers
- **`javascript_app/views/index.ejs`** — Server-rendered dashboard template
- **`javascript_app/public/style.css`** — Dashboard styling
- **`javascript_app/test/app.test.js`** — API and utility coverage using Node's test runner and Supertest

### Legacy iOS App

SwiftUI App with ObservableObject pattern:

- **HomeMonitoringApp.swift** — `@main` App struct entry point, uses `@UIApplicationDelegateAdaptor` to retain AppDelegate
- **AppDelegate.swift** — Initializes `ESTBeaconManager`, requests location authorization, configures Estimote Cloud credentials
- **BeaconManager.swift** — `ObservableObject` conforming to `ESTDeviceManagerDelegate` and `ESTDeviceConnectableDelegate`; encapsulates beacon discovery, connection, and sensor reading with `@Published` properties for temperature, pressure, and connection state
- **ContentView.swift** — SwiftUI view displaying temperature/pressure readings with background image and styled labels
- **ObjCBridge.h** — Bridging header that imports the Estimote Objective-C SDK for use in Swift

**Data flow:** App launch → AppDelegate configures Estimote SDK → ContentView appears → BeaconManager starts discovery → device connection → read temperature/pressure sensors → `@Published` properties update UI

## Key Details

- JavaScript app default port: `3000`
- JavaScript app requires Node.js 20+
- Bundle ID: `me.home-monitoring`
- Minimum deployment target: iOS 17.0
- Swift language version: 6.0
- iPhone only, portrait orientation
- No storyboards (pure SwiftUI)
- No test targets, linting, or CI/CD are configured
- The EstimoteSDK.framework binary (~99MB) is embedded directly in `home-monitoring/`
