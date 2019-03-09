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
import SVProgressHUD

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var conditionIconImage: UIImageView!
    
    let WEATHER_API_URL = "http://api.openweathermap.org/data/2.5/weather"
    let WEATHER_API_KEY = "d46219087443a7abcb091c12140b29b2"
    let locationManager = CLLocationManager()
    var firstOpen = true
    var searchNotFound = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // conditionLabel.font = UIFont(name: "Lato", size: 50.0)
        // cityNameLabel.font = UIFont.boldSystemFont(ofSize: 50.0)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToChangeLocation" {
            let destinationVC = segue.destination as! ChangeLocationViewController
            
            destinationVC.delegate = self
        }
    }
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToChangeLocation", sender: self)
    }
    
    func getWeatherData(lat: String, lon: String) {
        let weatherParams: [String: String] = [
            "lat": lat,
            "lon": lon,
            "appid": WEATHER_API_KEY
        ]
        
        if firstOpen {
            SVProgressHUD.show()
        }
        
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
                
                if self.firstOpen {
                    SVProgressHUD.dismiss()
                    self.firstOpen = false
                }
                
                if json["cod"].intValue >= 400 {
                    self.searchNotFound = true
                } else {
                    self.searchNotFound = false
                }
                
                self.updateUI(data: json)
            } else {
                print("Error obtained Weather API Data: \(response.error!)")
                
                if self.firstOpen {
                    SVProgressHUD.dismiss()
                    self.firstOpen = false
                }
                
                self.conditionLabel.text = "Connection Issues"
                self.cityNameLabel.text = ""
            }
        }
    }
    
    func getWeatherBySearch(location: String) {
        let weatherParams: [String: String] = [
            "q": location,
            "appid": WEATHER_API_KEY
        ]
        
//        if firstOpen {
//            SVProgressHUD.show()
//        }
        
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
                
//                if self.firstOpen {
//                    SVProgressHUD.dismiss()
//                    self.firstOpen = false
//                }
                
                print("-----------------------> Searching....")
                print(json)
                
                if json["cod"].intValue >= 400 {
                    self.searchNotFound = true
                } else {
                    self.searchNotFound = false
                }
            
                self.updateUI(data: json)
            } else {
                print("Error obtained Weather API Data: \(response.error!)")
                
//                if self.firstOpen {
//                    SVProgressHUD.dismiss()
//                    self.firstOpen = false
//                }
                
                self.conditionLabel.text = "Weather Unavailable"
                self.cityNameLabel.text = ""
            }
        }
    }
    
    func updateUI(data: JSON) {
        if searchNotFound {
            conditionLabel.text = "Weather Unavailable"
            cityNameLabel.text = ""
        } else {
            conditionLabel.text = String(data["weather"][0]["main"].stringValue)
            cityNameLabel.text = String(data["name"].stringValue)
            conditionIconImage.image = UIImage(named: getWeatherIcon(condition: data["weather"][0]["id"].intValue))
        }
    }
    
    func getWeatherIcon(condition: Int) -> String {
        
        switch (condition) {
            
        case 0...300 :
            return "tstorm1"
            
        case 301...500 :
            return "light_rain"
            
        case 501...600 :
            return "shower3"
            
        case 601...700 :
            return "snow4"
            
        case 701...771 :
            return "fog"
            
        case 772...799 :
            return "tstorm3"
            
        case 800 :
            return "sunny"
            
        case 801...804 :
            return "cloudy2"
            
        case 900...903, 905...1000  :
            return "tstorm3"
            
        case 903 :
            return "snow5"
            
        case 904 :
            return "sunny"
            
        default :
            return "dunno"
        }
    }
}

extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        let latitude = String(location.coordinate.latitude)
        let longitude = String(location.coordinate.longitude)
        
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            getWeatherData(lat: latitude, lon: longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error fail get user location: \(error)")
        
        conditionLabel.text = "Weather Unavailable"
    }
}

extension WeatherViewController: ReceivedSearchLocation {
    func receiveSearchValue(val: String) {
        getWeatherBySearch(location: val)
    }
}
