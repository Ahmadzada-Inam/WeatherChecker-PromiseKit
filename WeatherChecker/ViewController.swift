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
        handleMockLocation()
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
        .done { [weak self] weatherInfo in
            DispatchQueue.main.async {
                self?.updateUI(with: weatherInfo)
            }
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
        
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        guard let _ = textField.text else { return false }
        
        handleMockLocation()
        
        return true
    }
}
