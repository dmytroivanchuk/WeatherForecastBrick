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
    
    var conditionName: String {
        switch conditionId {
        case 200...232:
            return "cloud.bolt"
        case 300...321:
            return "cloud.drizzle"
        case 500...531:
            return "cloud.rain"
        case 600...622:
            return "cloud.snow"
        case 701...781:
            return "cloud.fog"
        case 800:
            return "sun.max"
        case 801...804:
            return "cloud"
        default:
            return "cloud"
        }
    }
}
