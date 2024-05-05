//
//  WeatherModel.swift
//  WeatherAR
//
//  Created by Gaurav Patil on 5/2/24.
//

import Foundation

struct WeatherModel {
    let conditionId: Int
    let cityName: String
    let temperature: Double
    
    var tempString: String {
        return String(format: "%0.1F", temperature)
    }
    
    var conditionName: String{
        
        switch self.conditionId {
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
            return "cloud.bolt"
        default:
            return "cloud"
            
        }
    }
    
    var desc: String {
        switch self.conditionId {
        case 200...232:
            return "Thunderstorm around the corner, take care!"
        case 300...321:
            return "Take an umbrella and you will be fine"
        case 500...531:
            return "Be careful its raining"
        case 600...622:
            return "Time to make some snow man"
        case 701...781:
            return "If you can see you are good"
        case 800:
            return "Stay hydrated"
        case 801...804:
            return "Be careful thunder bolts are around"
        default:
            return "Cloudy but not shady, its fine"
            
        }
    }
}
