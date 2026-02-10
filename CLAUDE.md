# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Home Monitoring is an iOS app (Swift 4) that reads temperature and pressure data from Estimote BLE beacons. It uses the Estimote SDK to discover, connect to, and read sensor data from a configured beacon, displaying results on a single-screen UI.

## Build & Run

This is a native Xcode project with no package managers (no CocoaPods, Carthage, or SPM). The EstimoteSDK.framework is manually embedded.

- **Open:** `home-monitoring.xcodeproj` in Xcode
- **Build/Run:** Cmd+R (requires a physical iPhone with iOS 10.3+)
- **Testing requires:** a physical Estimote beacon device

### Required Setup Before Building

1. Set beacon identifier in `home-monitoring/ViewController.swift` (the `monitoringDeviceIdentifier` property)
2. Set Estimote Cloud credentials in `home-monitoring/AppDelegate.swift` via `ESTConfig.setupAppID(_:andAppToken:)`

## Architecture

Standard MVC pattern with two key files:

- **AppDelegate.swift** — Initializes `ESTBeaconManager`, requests location authorization
- **ViewController.swift** — Handles device discovery (`ESTDeviceManagerDelegate`), beacon connection (`ESTDeviceConnectableDelegate`), and displays temperature/pressure readings via IBOutlets connected to `Main.storyboard`
- **ObjCBridge.h** — Bridging header that imports the Estimote Objective-C SDK for use in Swift

**Data flow:** App launch → location permission → beacon discovery → device connection → read temperature/pressure sensors → update UI labels

## Key Details

- Bundle ID: `me.home-monitoring`
- Minimum deployment target: iOS 10.3
- iPhone only, portrait orientation
- No test targets, linting, or CI/CD are configured
- The EstimoteSDK.framework binary (~99MB) is embedded directly in `home-monitoring/`
