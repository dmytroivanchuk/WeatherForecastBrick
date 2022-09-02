//
//  WeatherManager.swift
//  WeatherForecastBrick
//
//  Created by Dmytro Ivanchuk on 23.08.2022.
//

import CoreLocation

protocol WeatherManagerProtocol {
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completion completionHandler: @escaping (Result<WeatherModel, WeatherManagerError>) -> Void)
}

// create WeatherManager struct, responsible for fetching current weather data using public API, based on user's coordinates
struct WeatherManager: WeatherManagerProtocol {
    
    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }
    
    private let urlSession: URLSession
    
    private var weatherURL: String {
        var keys: NSDictionary?

        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        } else {
            fatalError("Error fetching API keys from Keys.plist")
        }
        
        if let dict = keys {
            let apiKey = dict["parseAPIkey"] as! String
            return "https://api.openweathermap.org/data/2.5/weather?appid=\(apiKey)&units=metric"
        } else {
            fatalError("Error fetching API keys from Keys.plist")
        }
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completion completionHandler: @escaping (Result<WeatherModel, WeatherManagerError>) -> Void) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        if let url = URL(string: urlString) {
            let session = urlSession
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    completionHandler(Result.failure(WeatherManagerError.urlSessionError))
                    return
                }
                if let weatherData = data {
                    if let weatherModel = parseJSON(weatherData) {
                        completionHandler(Result.success(weatherModel))
                    } else {
                        completionHandler(Result.failure(WeatherManagerError.parseJSONError))
                    }
                }
            }
            task.resume()
        }
    }
    
    private func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let weatherModel = WeatherModel(weatherData: decodedData)
            return weatherModel
        } catch {
            return nil
        }
    }
}

enum WeatherManagerError: Error {
    case urlSessionError
    case parseJSONError
}
