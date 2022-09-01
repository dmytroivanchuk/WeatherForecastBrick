//
//  File.swift
//  WeatherForecastBrick
//
//  Created by Dmytro Ivanchuk on 01.09.2022.
//

import Foundation

// create HTTPClientFactory class, responsible for assigning the appropriate http client, based on app launch environment. For UI tests assign mock http client, for production assign default http client
class HTTPClientFactory {
    
    static func returnWeatherManager() -> WeatherManagerProtocol {
        let environment = ProcessInfo.processInfo.environment["ENV"]
        return environment == "UITEST" ? MockWeatherManager() : WeatherManager(urlSession: URLSession.shared)
    }
}
