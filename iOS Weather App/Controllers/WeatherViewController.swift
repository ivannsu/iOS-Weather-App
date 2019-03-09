//
//  ViewController.swift
//  iOS Weather App
//
//  Created by Ivan Su on 3/5/19.
//  Copyright © 2019 Ivan Su. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var cityNameLabel: UILabel!
    
    let WEATHER_API_URL = "http://api.openweathermap.org/data/2.5/weather"
    let WEATHER_API_KEY = "d46219087443a7abcb091c12140b29b2"
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func getWeatherData(lat: String, lon: String) {
        let weatherParams: [String: String] = [
            "lat": lat,
            "lon": lon,
            "appid": WEATHER_API_KEY
        ]
        
        Alamofire.request(WEATHER_API_URL, method: .get, parameters: weatherParams).responseJSON { response in
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                /*
                [
                 "name" : "Cupertino",
                 "weather" : [
                     {
                     "id" : 500,
                     "icon" : "10d",
                     "description" : "light rain",
                     "main" : "Rain"
                     }
                ]
                */
                
                self.updateUI(data: json)
            } else {
                print("Error obtained Weather API Data: \(response.error!)")
                self.conditionLabel.text = "Weather Unavailable"
            }
        }
    }
    
    func updateUI(data: JSON) {
        // print("JSON Data: \(data)")
        conditionLabel.text = String(data["weather"][0]["main"].stringValue)
        cityNameLabel.text = String(data["name"].stringValue)
    }
}

extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        let latitude = String(location.coordinate.latitude)
        let longitude = String(location.coordinate.longitude)
        
        getWeatherData(lat: latitude, lon: longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error fail get user location: \(error)")
        
        conditionLabel.text = "Weather Unavailable"
    }
}
