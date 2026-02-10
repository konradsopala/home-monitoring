# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Home Monitoring is an iOS app (Swift 6, iOS 17+) that reads temperature and pressure data from Estimote BLE beacons. It uses the Estimote SDK to discover, connect to, and read sensor data from a configured beacon, displaying results in a SwiftUI interface.

## Build & Run

This is a native Xcode project with no package managers (no CocoaPods, Carthage, or SPM). The EstimoteSDK.framework is manually embedded.

- **Open:** `home-monitoring.xcodeproj` in Xcode 15+
- **Build/Run:** Cmd+R (requires a physical iPhone with iOS 17+)
- **Testing requires:** a physical Estimote beacon device

### Required Setup Before Building

1. Set beacon identifier in `home-monitoring/BeaconManager.swift` (the `monitoringDeviceIdentifier` property)
2. Set Estimote Cloud credentials in `home-monitoring/AppDelegate.swift` via `ESTConfig.setupAppID(_:andAppToken:)`

## Architecture

SwiftUI App with ObservableObject pattern:

- **HomeMonitoringApp.swift** — `@main` App struct entry point, uses `@UIApplicationDelegateAdaptor` to retain AppDelegate
- **AppDelegate.swift** — Initializes `ESTBeaconManager`, requests location authorization, configures Estimote Cloud credentials
- **BeaconManager.swift** — `ObservableObject` conforming to `ESTDeviceManagerDelegate` and `ESTDeviceConnectableDelegate`; encapsulates beacon discovery, connection, and sensor reading with `@Published` properties for temperature, pressure, and connection state
- **ContentView.swift** — SwiftUI view displaying temperature/pressure readings with background image and styled labels
- **ObjCBridge.h** — Bridging header that imports the Estimote Objective-C SDK for use in Swift

**Data flow:** App launch → AppDelegate configures Estimote SDK → ContentView appears → BeaconManager starts discovery → device connection → read temperature/pressure sensors → `@Published` properties update UI

## Key Details

- Bundle ID: `me.home-monitoring`
- Minimum deployment target: iOS 17.0
- Swift language version: 6.0
- iPhone only, portrait orientation
- No storyboards (pure SwiftUI)
- No test targets, linting, or CI/CD are configured
- The EstimoteSDK.framework binary (~99MB) is embedded directly in `home-monitoring/`
