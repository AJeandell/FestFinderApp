//
//  FestFinderApp.swift
//  FestFinder
//
//  Created by Austin Jeandell on 3/17/24.
//

import SwiftUI
import CoreLocation
import Foundation

// Class and Variables
class Festivals {
    var name: String
    var date: String
    var longitude: String
    var latitude: String
    
    init(name: String, date: String, longitude: String, latitude: String) {
        self.name = name
        self.date = date
        self.longitude = longitude
        self.latitude = latitude
    }
    
}

let austincitylimits = Festivals(
    name:"Austin City Limits",
    date:"10/6/23 - 10/15/23",
    longitude: "-97.7431",
    latitude: "30.2672"
)



var constintR = 6371; // Earths Radius in KM

func toRadians(_ degree: Double) -> Double {
    return degree * .pi / 180
}

func calculateDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double, unit: String) throws -> Double {
    let R = 6371.0 // Earth's radius in kilometers

    guard lat1 >= -90, lat1 <= 90, lat2 >= -90, lat2 <= 90,
          lon1 >= -180, lon1 <= 180, lon2 >= -180, lon2 <= 180 else {
        throw NSError(domain: "Invalid input",
                      code: 1,
                      userInfo: [NSLocalizedDescriptionKey: "Latitude must be between -90 and 90, longitude must be between -180 and 180"])
    }

    let lat1Rad = toRadians(lat1)
    let lon1Rad = toRadians(lon1)
    let lat2Rad = toRadians(lat2)
    let lon2Rad = toRadians(lon2)

    let latitudeDifferenceRad = lat2Rad - lat1Rad
    let longitudeDifferenceRad = lon2Rad - lon1Rad

    let a = sin(latitudeDifferenceRad / 2) * sin(latitudeDifferenceRad / 2) +
            cos(lat1Rad) * cos(lat2Rad) *
            sin(longitudeDifferenceRad / 2) * sin(longitudeDifferenceRad / 2)
    let c = 2 * atan2(sqrt(a), sqrt(1 - a))

    if unit == "KM" {
        return R * c
    } else if unit == "Miles" {
        return R * c * 0.621371
    } else {
        throw NSError(domain: "Invalid unit of distance",
                      code: 2,
                      userInfo: [NSLocalizedDescriptionKey: "Unit must be 'KM' or 'Miles'"])
    }
}

enum LocationError: Error {
    case locationUnavailable
    case permissionDenied
}

func getUserLocation(completion: @escaping (Result<(lat: Double, lon: Double), LocationError>) -> Void) {
    let locationManager = CLLocationManager()
    locationManager.desiredAccuracy = kCLLocationAccuracyBest

    // Check if location services are enabled
    if CLLocationManager.locationServicesEnabled() {
        locationManager.requestWhenInUseAuthorization()

        locationManager.requestLocation { (location, error) in
            if let error = error {
                if error.code == CLError.locationUnknown.rawValue {
                    completion(.failure(.locationUnavailable))
                } else {
                    completion(.failure(.permissionDenied))
                }
            } else if let location = location {
                completion(.success((lat: location.coordinate.latitude, lon: location.coordinate.longitude)))
            }
        }
    } else {
        completion(.failure(.permissionDenied))
    }
}


struct Festival {
    let name: String
    let lat: Double
    let lon: Double
}

enum DistanceUnit {
    case kilometers
    case miles
}

func calculateDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double, unit: DistanceUnit) -> Double {
    let R = unit == .kilometers ? 6371.0 : 6371.0 * 0.621371 // Earth's radius in kilometers or miles

    let lat1Rad = lat1 * .pi / 180
    let lon1Rad = lon1 * .pi / 180
    let lat2Rad = lat2 * .pi / 180
    let lon2Rad = lon2 * .pi / 180

    let latitudeDifferenceRad = lat2Rad - lat1Rad
    let longitudeDifferenceRad = lon2Rad - lon1Rad

    let a = sin(latitudeDifferenceRad / 2) * sin(latitudeDifferenceRad / 2) +
            cos(lat1Rad) * cos(lat2Rad) *
            sin(longitudeDifferenceRad / 2) * sin(longitudeDifferenceRad / 2)
    let c = 2 * atan2(sqrt(a), sqrt(1 - a))

    return R * c
}

func getClosestFestivals(userLat: Double, userLon: Double, unit: DistanceUnit, festivals: [Festival]) -> [(name: String, distance: Double)] {
    let distances = festivals.map { festival -> (name: String, distance: Double) in
        let distance = calculateDistance(lat1: userLat, lon1: userLon, lat2: festival.lat, lon2: festival.lon, unit: unit)
        return (name: festival.name, distance: distance)
    }
    return distances.sorted { $0.distance < $1.distance }
}

@main
struct FestFinderApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
