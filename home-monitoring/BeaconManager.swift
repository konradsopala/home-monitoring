//
//  BeaconManager.swift
//  home-monitoring
//
//  Created by Konrad on 12.06.2017.
//  Copyright © 2017 Konrad. All rights reserved.
//

import Foundation
import Combine

enum ConnectionState: Equatable {
    case disconnected
    case searching
    case connecting
    case connected
    case error(String)
}

class BeaconManager: NSObject, ObservableObject {

    // MARK: Published properties

    @Published var temperature: Int?
    @Published var pressure: Int?
    @Published var connectionState: ConnectionState = .disconnected

    // MARK: Beacon properties

    private var monitoringDevice: ESTDeviceLocationBeacon?

    // TODO: Insert your beacon identifier here to compile
    private let monitoringDeviceIdentifier: String = <#Your beacon identifier#>

    private lazy var deviceManager: ESTDeviceManager = {
        let manager = ESTDeviceManager()
        manager.delegate = self
        return manager
    }()

    // MARK: Methods

    func startSearching() {
        connectionState = .searching
        let filter = ESTDeviceFilterLocationBeacon(identifier: monitoringDeviceIdentifier)
        deviceManager.startDeviceDiscovery(with: filter)
    }

    func stopSearching() {
        deviceManager.stopDeviceDiscovery()
        monitoringDevice?.disconnect()
        connectionState = .disconnected
    }
}

// MARK: - ESTDeviceManagerDelegate

extension BeaconManager: ESTDeviceManagerDelegate {

    func deviceManager(_ manager: ESTDeviceManager, didDiscover devices: [ESTDevice]) {
        guard let device = devices.first as? ESTDeviceLocationBeacon else { return }
        deviceManager.stopDeviceDiscovery()
        monitoringDevice = device
        monitoringDevice?.delegate = self
        monitoringDevice?.connect()
        connectionState = .connecting
    }
}

// MARK: - ESTDeviceConnectableDelegate

extension BeaconManager: ESTDeviceConnectableDelegate {

    func estDeviceConnectionDidSucceed(_ device: ESTDeviceConnectable) {
        print("Connection Output Status: Connected")
        let rawPressure = monitoringDevice?.settings?.sensors.pressure.getValue()
        let rawTemperature = monitoringDevice?.settings?.sensors.temperature.getValue()
        Task { @MainActor in
            connectionState = .connected
            if let rawPressure {
                pressure = Int(rawPressure / 100)
            }
            if let rawTemperature {
                temperature = Int(rawTemperature)
            }
        }
    }

    func estDevice(_ device: ESTDeviceConnectable, didFailConnectionWithError error: Error) {
        print("Connection Output Status: \(error.localizedDescription)")
        Task { @MainActor in
            connectionState = .error(error.localizedDescription)
        }
    }

    func estDevice(_ device: ESTDeviceConnectable, didDisconnectWithError error: Error?) {
        print("Connection Output Status: Disconnected")
        Task { @MainActor in
            connectionState = .disconnected
        }
    }
}
