//
//  LocationRequester.swift
//  LambdaTimeline
//
//  Created by Kelson Hartle on 7/9/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreLocation

class LocationRequester: NSObject {

    private lazy var manager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.delegate = self
        return manager
    }()

    var lastLocation: CLLocationCoordinate2D?

    var isAuthorized: Bool {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        default:
            return false
        }
    }

    func requestAuth() {
        manager.requestWhenInUseAuthorization()
    }

    func singleLocationRequest() {
        manager.requestLocation()
    }

    func startTrackingLocation() {
        manager.startUpdatingLocation()
    }

    func stopTrackingLocation() {
        manager.stopUpdatingLocation()
    }
}

extension LocationRequester: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        lastLocation = location.coordinate
    }
}
