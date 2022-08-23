//
//  WeatherData.swift
//  WeatherForecastBrick
//
//  Created by Dmytro Ivanchuk on 23.08.2022.
//

struct WeatherData: Codable {
    let weather: [Weather]
    let main: Main
    let sys: Sys
    let name: String
}

struct Weather: Codable {
    let id: Int
    let description: String
}

struct Main: Codable {
    let temp: Double
}

struct Sys: Codable {
    let country: String
}

