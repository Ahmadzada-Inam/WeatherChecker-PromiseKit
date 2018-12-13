//
//  LocationHelper.swift
//  WeatherChecker
//
//  Created by Inam Ahmad-zada on 2018-12-12.
//  Copyright © 2018 Inam Ahmad-zada. All rights reserved.
//

import Foundation
import CoreLocation
import PromiseKit

class LocationHelper {
    let coder = CLGeocoder()
    
    func getLocation() -> Promise<CLPlacemark> {
        return CLLocationManager.requestLocation().lastValue.then { location in
            return self.coder.reverseGeocode(location: location).firstValue
        }
    }
    
    func searchForPlacemark(text: String) -> Promise<CLPlacemark> {
        return coder.geocode(text).firstValue
    }
}
