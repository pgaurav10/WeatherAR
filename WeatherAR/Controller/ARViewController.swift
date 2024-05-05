//
//  ARViewController.swift
//  WeatherAR
//
//  Created by Gaurav Patil on 5/2/24.
//

import UIKit
import SceneKit
import ARKit
import RealityKit

class ARViewController: UIViewController, ARSCNViewDelegate {
    
    var arView: ARView = {
        let arView = ARView(frame: .zero, cameraMode: .ar)
        arView.translatesAutoresizingMaskIntoConstraints = false
        return arView
    }()
    
    var weatherModelAnchor: AnchorEntity?
    var isWeatherModelPresent: Bool = false
    
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
    var weatherMg = WeatherManager()
    var locationMg = CLLocationManager()
    var temptext: String = "0.00"
    var descText: String = "World is sunny and happy"
    var cityName: String = "No City"
    var initialPinchScale: CGFloat = 1.0
    var initialPanLocation: CGPoint = .zero
    var worldPosition: simd_float3?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationMg.delegate = self
        searchLoc.delegate = self
        weatherMg.delegate = self
        
        setupViews()
        
    }
    
    func setupViews() {
        self.view.addSubview(arView)
        
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
        
        NSLayoutConstraint.activate([
            stackView1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView1.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            stackView1.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            arView.topAnchor.constraint(equalTo: stackView1.bottomAnchor, constant: 20),
            arView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            arView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            arView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -75)
        ])
    }
    @objc func navButtonPressed() {
        print("Nav Here")
        locationMg.requestLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        configuration.environmentTexturing = .automatic
        
        arView.session.run(configuration)
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(recognizer:))))
        arView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:))))
        arView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:))))
        
    }
    
    @objc func handlePinch(_ gestureRecognizer: UIPinchGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }
        
        if gestureRecognizer.state == .began {
            initialPinchScale = gestureRecognizer.scale
        }
        
        if gestureRecognizer.state == .changed {
            let scale = gestureRecognizer.scale / initialPinchScale
            adjustCameraZoom(scale: scale)
        }
    }
    
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let selectedEntity = arView.scene.findEntity(named: "weatherModel") else { return }

        // Get translation in view coordinates
        let translation = gestureRecognizer.translation(in: arView)

        switch gestureRecognizer.state {
        case .began:
           // Get initial location of pan gesture
           initialPanLocation = gestureRecognizer.location(in: arView)
       case .changed:
           // Calculate rotation based on pan gesture
           let location = gestureRecognizer.location(in: arView)
           let deltaX = Float(location.x - initialPanLocation.x) * 0.01
           let deltaY = Float(location.y - initialPanLocation.y) * 0.01

           // Apply rotation to the selected entity
           let rotation = selectedEntity.transform.rotation
           let newRotation = simd_quatf(angle: deltaX, axis: [0, 1, 0]) * simd_quatf(angle: deltaY, axis: [1, 0, 0]) * rotation
           selectedEntity.transform.rotation = newRotation
        default:
            break
        }
    }
    
    func adjustCameraZoom(scale: CGFloat) {
        let scaleFactor: Float = Float(scale)

        for anchor in arView.scene.anchors {
            anchor.transform.scale *= SIMD3<Float>(repeating: scaleFactor)
        }

    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
            
        let tapLocation = recognizer.location(in: arView)
        
        let results = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
        

        if let firstResult = results.first {
            
            worldPosition = simd_make_float3(firstResult.worldTransform.columns.3)
            updateModel()
        }
    
    }
    
    func updateModel() {
        
        if isWeatherModelPresent {
            arView.scene.findEntity(named: "weatherModel")?.removeFromParent()
        }
        
        if let safePosition = worldPosition {
            weatherModelAnchor = AnchorEntity(world: safePosition)
            
            let mesh = MeshResource.generateText("\(self.cityName):  \(self.temptext)°C \n\(self.descText)", extrusionDepth: 0.1, font: .systemFont(ofSize: 2), containerFrame: .zero, alignment: .left, lineBreakMode: .byTruncatingTail)
            let material = SimpleMaterial(color: .black, isMetallic: true)
            
            let model = ModelEntity(mesh: mesh, materials: [material])
            model.scale = SIMD3<Float>(x: 0.03, y: 0.03, z: 0.01)
            
            model.name = "weatherModel"
            weatherModelAnchor!.addChild(model)
            
            arView.scene.addAnchor(weatherModelAnchor!)
            isWeatherModelPresent = true
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    
        arView.session.pause()
    }
}
//MARK: - Textfield Delegate
extension ARViewController: UITextFieldDelegate {
    
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
extension ARViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationMg.stopUpdatingLocation()
            weatherMg.getWeather(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}
//MARK: - Weather Manager Delegate
extension ARViewController: WeatherManagerDelegate {
    func didUpdateWeather(_ weatherMg: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            
            self.temptext = weather.tempString
            self.descText = weather.desc
            self.cityName = weather.cityName
            self.updateModel()
        }
    }
    
    func didFailWithError(error: any Error) {
        print("Error: \(error.localizedDescription)")
    }
}
