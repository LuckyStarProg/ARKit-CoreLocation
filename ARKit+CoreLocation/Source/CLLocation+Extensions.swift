//
//  CLLocation+Extensions.swift
//  ARKit+CoreLocation
//
//  Created by Andrew Hart on 02/07/2017.
//  Copyright © 2017 Project Dent. All rights reserved.
//

import Foundation
import CoreLocation

///Translation in meters between 2 locations
struct LocationTranslation {
    var latitudeTranslation: Double
    var longitudeTranslation: Double
}

extension CLLocation {
    ///Translates distance in meters between two locations.
    ///Returns the result as the distance in latitude and distance in longitude.
    func translation(toLocation location: CLLocation) -> LocationTranslation {
        let inbetweenLocation = CLLocation(latitude: self.coordinate.latitude, longitude: location.coordinate.longitude)
        
        let distanceLatitude = location.distance(from: inbetweenLocation)
        
        let latitudeTranslation: Double
        
        if location.coordinate.latitude > inbetweenLocation.coordinate.latitude {
            latitudeTranslation = distanceLatitude
        } else {
            latitudeTranslation = 0 - distanceLatitude
        }
        
        let distanceLongitude = self.distance(from: inbetweenLocation)
        
        let longitudeTranslation: Double
        
        if self.coordinate.longitude > inbetweenLocation.coordinate.longitude {
            longitudeTranslation = 0 - distanceLongitude
        } else {
            longitudeTranslation = distanceLongitude
        }
        
        return LocationTranslation(latitudeTranslation: latitudeTranslation, longitudeTranslation: longitudeTranslation)
    }
    
    func translatedLocation(with translation: LocationTranslation) -> CLLocation {
        let latitudeCoordinate = self.coordinate.coordinateWithBearing(bearing: 0, distanceMeters: translation.latitudeTranslation)
        
        let longitudeCoordinate = self.coordinate.coordinateWithBearing(bearing: 90, distanceMeters: translation.longitudeTranslation)
        
        let location = CLLocation(
            latitude: latitudeCoordinate.latitude,
            longitude: longitudeCoordinate.longitude)
        
        return location
    }
}

extension CLLocationCoordinate2D {
    func coordinateWithBearing(bearing:Double, distanceMeters:Double) -> CLLocationCoordinate2D {
        //The numbers for earth radius may be _off_ here
        //but this gives a reasonably accurate result..
        //Any correction here is welcome.
        let distRadiansLat = distanceMeters / (6360500.0) // earth radius in meters latitude
        let distRadiansLong = distanceMeters / (5602900.0) // earth radius in meters longitude
        
        let lat1 = self.latitude * Double.pi / 180
        let lon1 = self.longitude * Double.pi / 180
        
        let lat2 = asin(sin(lat1) * cos(distRadiansLat) + cos(lat1) * sin(distRadiansLat) * cos(bearing))
        let lon2 = lon1 + atan2(sin(bearing) * sin(distRadiansLong) * cos(lat1), cos(distRadiansLong) - sin(lat1) * sin(lat2))
        
        return CLLocationCoordinate2D(latitude: lat2 * 180 / Double.pi, longitude: lon2 * 180 / Double.pi)
    }
}
