//
//  WeatherHelper.swift
//  WeatherChecker
//
//  Created by Inam Ahmad-zada on 2018-12-12.
//  Copyright © 2018 Inam Ahmad-zada. All rights reserved.
//

import Foundation
import PromiseKit

private let appID = "936e32ee03f4ef7116f9f7d75366f8ea"

class WeatherHelper {
    
    struct WeatherInfo: Codable {
        let main: Temperature
        let weather: [Weather]
        var name: String = "Error: invalid jsonDictionary! Verify your appID is correct"
    }
    
    struct Weather: Codable {
        let icon: String
        let description: String
    }
    
    struct Temperature: Codable {
        let temp: Double
    }
    
    func getWeather(coordinate: CLLocationCoordinate2D) -> Promise<WeatherInfo> {
        let urlString = "http://api.openweathermap.org/data/2.5/weather?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&appid=\(appID)"
        
        let url = URL(string: urlString)!
        
        return firstly {
            URLSession.shared.dataTask(.promise, with: url)
        }.compactMap {
            return try JSONDecoder().decode(WeatherInfo.self, from: $0.data)
        }
    }
    
    private func saveFile(named: String, data: Data, completion: @escaping (Error?) -> Void) {
        guard let path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent(named+".png") else { return }
        
        DispatchQueue.global(qos: .background).async {
            do {
                try data.write(to: path)
                print("Saved image to: " + path.absoluteString)
                completion(nil)
            }
            catch {
                completion(error)
            }
        }
    }
    
    private func getFile(named: String, completion: @escaping (UIImage?, Error?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            if let path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent(named+".png"),
            let data = try? Data(contentsOf: path),
                let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image, nil)
                }
            }
            else {
                let error = NSError(domain: "WeatherChecker", code: 0, userInfo: [NSLocalizedDescriptionKey: "Image file named '\(named)' not found."])
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }
}
