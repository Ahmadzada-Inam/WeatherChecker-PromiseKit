//
//  ViewController.swift
//  WeatherChecker
//
//  Created by Inam Ahmad-zada on 2018-12-12.
//  Copyright © 2018 Inam Ahmad-zada. All rights reserved.
//

import UIKit
import CoreLocation
import PromiseKit

private let errorColor = UIColor(red: 0.96, green: 0.667, blue: 0.690, alpha: 1.0)
private let oneHour: TimeInterval = 3600
private let randomCities = [("Tokyo", "JP", 35.683333, 139.683333),
                            ("Jakarta", "ID", -6.2, 106.816667),
                            ("Delhi", "IN", 28.61, 77.23),
                            ("Manila", "PH", 14.58, 121),
                            ("São Paulo", "BR", -23.55, -46.633333)]

class ViewController: UIViewController {
    
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var randomWeatherButton: UIButton!
    
    let weatherApi = WeatherHelper()
    let locationHelper = LocationHelper()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateWithCurrentLocation()
    }
    
    private func updateWithCurrentLocation() {
        locationHelper.getLocation()
        .done { [weak self] placemark in
            self?.handleLocation(placemark: placemark)
        }
        .catch { [weak self] error in
            guard let self = self else { return }
            
            self.tempLabel.text = "--"
            self.placeLabel.text = "--"
            
            switch error {
            case is CLError where (error as? CLError)?.code == .denied:
                self.conditionLabel.text = "Enable Location Permissions in Settings"
                self.conditionLabel.textColor = UIColor.white
            default:
                self.conditionLabel.text = error.localizedDescription
                self.conditionLabel.textColor = errorColor
            }
        }
    }
    
    private func handleMockLocation() {
        let coordinate = CLLocationCoordinate2DMake(37.966667, 23.716667)
        handleLocation(city: "Athens", state: "Greece", coordinate: coordinate)
    }
    
    private func handleLocation(placemark: CLPlacemark) {
        handleLocation(city: placemark.locality, state: placemark.administrativeArea, coordinate: placemark.location!.coordinate)
    }
    
    private func handleLocation(city: String?, state: String?, coordinate: CLLocationCoordinate2D) {
        if let city = city, let state = state {
            placeLabel.text = "\(city), \(state)"
        }
        
        weatherApi.getWeather(coordinate: coordinate)
        .then { [weak self] weatherInfo -> Promise<UIImage> in
            guard let self = self else { return brokenPromise() }
            
            DispatchQueue.main.async {
                self.updateUI(with: weatherInfo)
            }
            
            return self.weatherApi.getIcon(named: weatherInfo.weather.first!.icon)
        }
        .done(on: DispatchQueue.main) { (icon) in
            self.iconImageView.image = icon
        }
        .catch { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.tempLabel.text = "--"
                self.conditionLabel.text = error.localizedDescription
                self.conditionLabel.textColor = errorColor
            }
        }
    }
    
    private func updateUI(with weatherInfo: WeatherHelper.WeatherInfo) {
        let tempMeasurement = Measurement(value: weatherInfo.main.temp, unit: UnitTemperature.kelvin)
        let formatter = MeasurementFormatter()
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .none
        formatter.numberFormatter = numberFormatter
        
        let tempString = formatter.string(from: tempMeasurement)
        self.tempLabel.text = tempString
        self.placeLabel.text = weatherInfo.name
        self.conditionLabel.text = weatherInfo.weather.first?.description ?? "Empty"
        self.conditionLabel.textColor = .white
    }
    
    @IBAction func showRandomWeather(_ sender: UIButton) {
        randomWeatherButton.isEnabled = false
        
        let weatherPromises = randomCities.map {
            weatherApi.getWeather(coordinate: CLLocationCoordinate2D(latitude: $0.2, longitude: $0.3))
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        race(weatherPromises)
            .then { [weak self] weatherInfo -> Promise<UIImage> in
                guard let self = self else { return brokenPromise() }
                
                self.placeLabel.text = weatherInfo.name
                self.updateUI(with: weatherInfo)
                return self.weatherApi.getIcon(named: weatherInfo.weather.first!.icon)
            }
            .done { icon in
                self.iconImageView.image = icon
            }
            .catch { error in
                self.tempLabel.text = "--"
                self.conditionLabel.text = error.localizedDescription
                self.conditionLabel.textColor = errorColor
            }
            .finally {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.randomWeatherButton.isEnabled = true
        }
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        guard let text = textField.text else { return false }
        locationHelper.searchForPlacemark(text: text)
        .done { placemark in
            self.handleLocation(placemark: placemark)
        }
        .catch { _ in }
        
        return true
    }
}
