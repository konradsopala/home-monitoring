//
//  AppDelegate.swift
//  home-monitoring
//
//  Created by Konrad on 12.06.2017.
//  Copyright © 2017 Konrad. All rights reserved.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate, ESTBeaconManagerDelegate {

    let beaconManager = ESTBeaconManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        beaconManager.delegate = self
        beaconManager.requestAlwaysAuthorization()

        // TODO: Insert your AppID and AppToken here to compile (from Estimote Cloud)
        ESTConfig.setupAppID(<#Your AppID#>, andAppToken: <#Your AppToken#>)

        return true
    }
}
