//
//  WeatherModel.swift
//  Weather App
//
//  Created by Justin Deng on 6/2/22.
//

import Foundation
import CoreLocation

struct weatherData: Codable, Hashable{
    var lat : Float
    var lon : Float
    var timezone : String
    var timezone_offset : Int
    var current : current
    var daily : [daily]
}

struct current: Codable, Hashable{
    var dt : Int
    var sunrise : Int
    var sunset : Int
    var temp : Float
    var feels_like : Float
    var pressure : Int
    var humidity : Int
    var dew_point : Float
    var uvi : Float
    var clouds : Int
    var visibility : Int
    var wind_speed : Float
    var wind_deg : Int
    var weather : [weather]
}


struct weather: Codable, Hashable{
    var main : String
    var description : String
    var icon : String
}

struct daily : Codable, Hashable{
    var dt : Int
    var temp : temp
    var weather : [weather]
}


struct temp : Codable, Hashable{
    var day : Float
    var min : Float
    var max : Float
    var night : Float
    var eve : Float
    var morn : Float
}


class weatherApi : ObservableObject{
    @Published var results_ : [weatherData] = []
    let locationManager = CLLocationManager()
    
    init(){
        
        locationManager.requestWhenInUseAuthorization()
        let latitude = locationManager.location?.coordinate.latitude
        let longitude = locationManager.location?.coordinate.longitude
        
        
        
        loadData(lat: latitude ?? 0.0, long: longitude ?? 0.0)
    }
    
    
    func reload(){
        let latitude = locationManager.location?.coordinate.latitude
        let longitude = locationManager.location?.coordinate.longitude
        loadData(lat: latitude ?? 0.0, long: longitude ?? 0.0)
        
    }
    
    func loadData(lat : Double, long: Double){
        guard let url = URL(string: "https://api.openweathermap.org/data/3.0/onecall?lat=\(lat)&lon=\(long)&exclude=hourly,minutely&appid=\(Bundle.main.infoDictionary?["ClientKey"]  as? String ?? "API KEY GA KE FETCH")") else{
            fatalError("Invalid URL")
        }
        
        URLSession.shared.dataTask(with: url){ data, response, error in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                let results = try! JSONDecoder().decode(weatherData.self, from: data!)
                let tempArray = [results]
                self.results_ = tempArray
                print("api call finished")
        }
            
        }.resume()
        return
    }
}




