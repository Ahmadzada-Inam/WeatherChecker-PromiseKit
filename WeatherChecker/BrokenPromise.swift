//
//  BrokenPromise.swift
//  WeatherChecker
//
//  Created by Inam Ahmad-zada on 2018-12-12.
//  Copyright © 2018 Inam Ahmad-zada. All rights reserved.
//

import Foundation
import PromiseKit

func brokenPromise<T> (method: String = #function) -> Promise<T> {
    return Promise<T> { seal in
        let error = NSError(domain: "WeatherChecker", code: 0, userInfo: [NSLocalizedDescriptionKey: "'\(method)' not yet implemented."])
        return seal.reject(error)
    }
}
