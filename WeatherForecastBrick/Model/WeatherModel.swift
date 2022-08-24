//
//  WeatherModel.swift
//  WeatherForecastBrick
//
//  Created by Dmytro Ivanchuk on 23.08.2022.
//

import CoreLocation

struct WeatherModel {
    let conditionId: Int
    let condition: String
    let temperature: Double
    let countryCode: String
    let cityName: String
    
    var countryName: String? {
        Locale(identifier: countryCode).localizedString(forRegionCode: countryCode)
    }
    
    var temperatureString: String {
        String(format: "%.0f", temperature)
    }
    
    var conditionImage: String {
        switch conditionId {
        case 200...531:
            return "rain.png"
        case 600...622:
            return "snow.png"
        case 701...781:
            return "fog.png"
        case 800...804:
            return temperature < 30 ? "sun.png" : "sun_veryHot.png"
        default:
            return "sun.png"
        }
    }
}
