//
//  ViewController.swift
//  WeatherForecastBrick
//
//  Created by Dmytro Ivanchuk on 22.08.2022.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet var weatherConditionImageView: UIImageView!
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var weatherConditionLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var infoButton: UIButton!
    
    let locationManager = CLLocationManager()
    var weatherManager = WeatherManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        weatherManager.delegate = self

        infoButton.layer.cornerRadius = 15
        infoButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    @IBAction func infoButtonPressed(_ sender: UIButton) {
    }
}

//MARK: - CLLocationManagerDelegate Methods

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let long = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: long)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

//MARK: - WeatherManagerDelegate Methods

extension ViewController: WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.weatherConditionImageView.image = UIImage(named: weather.conditionImage)
            self.temperatureLabel.text = "\(weather.temperatureString)°"
            self.weatherConditionLabel.text = weather.condition
            
            let fullString = NSMutableAttributedString(string: "")
            
            let image1Attachment = NSTextAttachment()
            image1Attachment.image = UIImage(named: "icon_location.png")
            let image1String = NSAttributedString(attachment: image1Attachment)
            
            let image2Attachment = NSTextAttachment()
            image2Attachment.image = UIImage(named: "icon_search.png")
            let image2String = NSAttributedString(attachment: image2Attachment)
            
            fullString.append(image1String)
            fullString.append(NSAttributedString(string: " \(weather.cityName), \(weather.countryName ?? "") "))
            fullString.append(image2String)
            
            self.locationLabel.attributedText = fullString
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}

