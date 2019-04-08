//
//  WeatherViewController.swift
//  Clima
//
//  Created by Michael Gimara on 27/03/2019.
//  Copyright © 2019 Michael Gimara. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {

    //MARK: - Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "8c044588ab5c9d656a5c14bf05f35bcf"

    //MARK: - Variables
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()

    //MARK: - Outlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier,
           identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }

    //MARK: - Networking
    func getWeatherData(url: String, parameters: [String : String]) {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { (response) in
            if response.result.isSuccess {
                let weatherJSON: JSON = JSON(response.result.value!) // value != nil for sure!
                
                if weatherJSON["cod"] == 200 {
                    print("Success! Got the weather data")
                    self.updateWeatherData(json: weatherJSON)
                } else {
                    print(weatherJSON)
                    self.temperatureLabel.isHidden = true
                    self.weatherIcon.isHidden = true
                    self.cityLabel.text = "Weather Unavailable"
                }
            } else if response.result.isFailure {
                if let error = response.result.error {
                    print("Error: \(error.localizedDescription)")
                }
                
                self.temperatureLabel.isHidden = true
                self.weatherIcon.isHidden = true
                self.cityLabel.text = "Connection Issues"
            }
        }
    }

    //MARK: - JSON Parsing
    func updateWeatherData(json: JSON) {
        let temperatureInKelvin = json["main"]["temp"].doubleValue
        let cityName = json["name"].stringValue
        let condition = json["weather"][0]["id"].intValue

        weatherDataModel.temperature = Int((temperatureInKelvin - 273.15).rounded())// Convert Kelvin to Celsius
        weatherDataModel.city = cityName
        weatherDataModel.condition = condition
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
        
        updateUIWithWeatherData()
    }

    //MARK: - UI Updates
    func updateUIWithWeatherData() {
        cityLabel.text = weatherDataModel.city
        temperatureLabel.isHidden = false
        weatherIcon.isHidden = false
        temperatureLabel.text = "\(weatherDataModel.temperature)°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }

    //MARK: - Location Manager Delegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last,
               location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude

            let params: [String : String] =
            [
                "lat" : "\(latitude)",
                "lon" : "\(longitude)",
                "appid" : APP_ID
            ]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
        temperatureLabel.isHidden = true
        cityLabel.text = "Location Unavailable"
    }

    //MARK: - Change City Delegate Methods
    func userEnteredANewCityName(city: String) {
        let params: [String : String] =
        [
            "q" : city,
            "appid" : APP_ID
        ]

        getWeatherData(url: WEATHER_URL, parameters: params)
    }
}


