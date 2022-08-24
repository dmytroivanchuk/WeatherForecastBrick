//
//  WeatherManager.swift
//  WeatherForecastBrick
//
//  Created by Dmytro Ivanchuk on 23.08.2022.
//

import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=66a5e7323ac6dd5cf801a2be0c946647&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let weather = parseJSON(safeData) {
                        delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let cond = decodedData.weather[0].description
            let temp = decodedData.main.temp
            let code = decodedData.sys.country
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, condition: cond, temperature: temp, countryCode: code, cityName: name)
            return weather
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
