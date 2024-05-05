//
//  WeatherDelegate.swift
//  WeatherAR
//
//  Created by Gaurav Patil on 5/2/24.
//

import Foundation

protocol WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherMg: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}
