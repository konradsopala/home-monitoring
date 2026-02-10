//
//  ContentView.swift
//  home-monitoring
//
//  Created by Konrad on 12.06.2017.
//  Copyright © 2017 Konrad. All rights reserved.
//

import SwiftUI

struct ContentView: View {

    @StateObject private var beaconManager = BeaconManager()

    var body: some View {
        ZStack {
            Image("MonitoringScreen")
                .resizable()
                .ignoresSafeArea()

            VStack(spacing: 40) {
                ReadingLabel(
                    value: beaconManager.temperature,
                    unit: "°C"
                )

                ReadingLabel(
                    value: beaconManager.pressure,
                    unit: "hPa"
                )
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            beaconManager.startSearching()
        }
        .alert(
            "Detecting beacon",
            isPresented: showDetectingAlert
        ) {
            // No dismiss button — alert stays until connection succeeds
        } message: {
            Text("Looks like you're not connected to the beacon yet. Wait a few seconds!")
        }
    }

    private var showDetectingAlert: Binding<Bool> {
        Binding(
            get: { beaconManager.connectionState != .connected },
            set: { _ in }
        )
    }
}

// MARK: - ReadingLabel

private struct ReadingLabel: View {
    let value: Int?
    let unit: String

    var body: some View {
        Text(displayText)
            .font(.custom("Avenir-Black", size: 36))
            .foregroundStyle(.white)
    }

    private var displayText: String {
        if let value {
            return "\(value) \(unit)"
        }
        return "-- \(unit)"
    }
}

#Preview {
    ContentView()
}
