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
    
    let WEATHER_API_KEY = "d46219087443a7abcb091c12140b29b2"
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func getWeatherData(lat: String, lon: String) {
        let weatherParams: [String: String] = [
            "lat": lat,
            "lon": lon,
            "appid": WEATHER_API_KEY
        ]
        
        Alamofire.request(
            "http://samples.openweathermap.org/data/2.5/weather",
            method: .get,
            parameters: weatherParams
        ).responseJSON { response in
            if response.result.isSuccess {
                print("Success obtained weather api data")
                print("\(response.result.value!)")
            } else {
                print("Error obtained Weather API Data: \(response.error!)")
            }
        }
    }
}

extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        let latitude = String(location.coordinate.latitude)
        let longitude = String(location.coordinate.longitude)
        
        getWeatherData(lat: latitude, lon: longitude)
        
        // print("\(latitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error fail get user location: \(error)")
        
        conditionLabel.text = "Weather Unavailable"
    }
}
