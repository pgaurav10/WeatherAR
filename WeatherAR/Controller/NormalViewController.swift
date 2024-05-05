//
//  NormalViewController.swift
//  WeatherAR
//
//  Created by Gaurav Patil on 5/2/24.
//

import UIKit
import CoreLocation

class NormalViewController: UIViewController {

    let locButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "location.circle.fill"), for: .normal)
        button.addTarget(self, action: #selector(navButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.tintColor = .black
        return button
    }()
    
    let searchLoc: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Search"
        textField.textColor = .black
        return textField
    }()
    
    let searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        button.addTarget(self, action: #selector(locButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.tintColor = .black
        return button
    }()
    
    let cloudImage: UIImageView = {
        let image = UIImageView(image: UIImage(systemName: "sun.max"))
        image.widthAnchor.constraint(equalToConstant: 100).isActive = true
        image.heightAnchor.constraint(equalToConstant: 100).isActive = true
        image.translatesAutoresizingMaskIntoConstraints = false
        image.tintColor = .black
        return image
    }()
    
    let tempLabel: UILabel = {
        let label = UILabel()
        label.text = "21.06"
        label.font = UIFont.boldSystemFont(ofSize: 80)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        return label
    }()
    
    let suffixLabel: UILabel = {
        let label = UILabel()
        label.text = "°C"
        label.font = UIFont.systemFont(ofSize: 80)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        return label
    }()
    
    let locationText: UILabel = {
        let label = UILabel()
        label.text = "Mumbai"
        label.font = UIFont.systemFont(ofSize: 30)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        return label
    }()
    
    let blankView = UIView()
    
    var weatherMg = WeatherManager()
    var locationMg = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationMg.delegate = self
        searchLoc.delegate = self
        weatherMg.delegate = self
        
        locationMg.requestWhenInUseAuthorization()
        locationMg.requestLocation()
        
        setupViews()
    }
    
    func setupViews() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "background")
        
        self.view.addSubview(backgroundImage)
        self.view.sendSubviewToBack(backgroundImage)
        
        let stackView1 = UIStackView(arrangedSubviews: [locButton, searchLoc, searchButton])
        stackView1.axis = .horizontal
        stackView1.spacing = 20
        stackView1.alignment = .center
        stackView1.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView1)
        
        view.addSubview(cloudImage)
        
        let stackView2 = UIStackView(arrangedSubviews: [tempLabel, suffixLabel])
        stackView2.axis = .horizontal
        stackView2.spacing = 0
        stackView2.alignment = .trailing
        stackView2.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView2)
        view.addSubview(locationText)
        
        NSLayoutConstraint.activate([
            stackView1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView1.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            stackView1.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            cloudImage.topAnchor.constraint(equalTo: stackView1.bottomAnchor, constant: 40),
            cloudImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            stackView2.topAnchor.constraint(equalTo: cloudImage.bottomAnchor, constant: 20),
            stackView2.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            locationText.topAnchor.constraint(equalTo: stackView2.bottomAnchor, constant: 20),
            locationText.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
            
        ])
    }
    
    @objc func navButtonPressed() {
        locationMg.requestLocation()
    }
}
//MARK: - Weather Manager Delegate
extension NormalViewController: WeatherManagerDelegate {
    func didUpdateWeather(_ weatherMg: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.tempLabel.text = weather.tempString
            self.cloudImage.image = UIImage(systemName: weather.conditionName)
            self.locationText.text = weather.cityName
        }
    }
    
    func didFailWithError(error: any Error) {
        print("Error: \(error.localizedDescription)")
    }
}
//MARK: - TextField Delegate
extension NormalViewController: UITextFieldDelegate {
    
    @objc func locButtonPressed() {
        searchLoc.endEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let city = textField.text {
            print(city)
            weatherMg.getWeather(city: city)
        }
        searchLoc.text = ""
    }
}
//MARK: - Location Manager Delegate
extension NormalViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationMg.stopUpdatingLocation()
            weatherMg.getWeather(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Erro: \(error)")
    }
}
