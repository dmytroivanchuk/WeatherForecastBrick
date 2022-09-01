//
//  MockWeatherManager.swift
//  WeatherForecastBrick
//
//  Created by Dmytro Ivanchuk on 01.09.2022.
//

import CoreLocation

// create MockWeatherManager class, responsible for mocking default http client for UI tests
class MockWeatherManager: WeatherManagerProtocol {
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completion completionHandler: @escaping (WeatherModel?) -> Void) {
        // generate data representation of valid .json file
        guard let filePathString = Bundle(for: type(of: self)).path(forResource: "apiValidWeatherData", ofType: "json") else {
            fatalError(".json file is not found.")
        }
        guard let json = try? String(contentsOfFile: filePathString, encoding: .utf8) else {
            fatalError("Unable to convert .json file to String.")
        }

        // decode data from valid .json file
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: json.data(using: .utf8)!)
            let weatherModel = WeatherModel(weatherData: decodedData)
            completionHandler(weatherModel)
        } catch {
            completionHandler(nil)
        }
    }
}
