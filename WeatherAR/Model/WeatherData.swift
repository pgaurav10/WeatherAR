//
//  WeatherData.swift
//  WeatherAR
//
//  Created by Gaurav Patil on 5/2/24.
//

import Foundation

struct WeatherData: Codable {
    let name: String
    let main: Main
    let weather: [Weather]
}

struct Main: Codable {
    let temp: Double
}

struct Weather: Codable {
    let id: Int
}

