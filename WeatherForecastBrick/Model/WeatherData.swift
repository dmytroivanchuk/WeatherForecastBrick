//
//  WeatherData.swift
//  WeatherForecastBrick
//
//  Created by Dmytro Ivanchuk on 23.08.2022.
//

// create WeatherData struct, responsible for decoding data from JSON Object
struct WeatherData: Codable {
    let weather: [Weather]
    let main: Main
    let wind: Wind
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

struct Wind: Codable {
    let speed: Double
}

struct Sys: Codable {
    let country: String
}

