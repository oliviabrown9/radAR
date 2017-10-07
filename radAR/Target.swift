//
//  Target.swift
//  radAR
//
//  Created by Olivia Brown on 10/7/17.
//  Copyright © 2017 Olivia Brown. All rights reserved.
//

import Foundation
import CoreLocation
import SceneKit

struct Target {

    let id: String
    let long: Double
    let lat: Double
    
    init(id: String, lat: Double, long: Double) {
        self.id = id
        self.lat = lat
        self.long = long
    }
    
    init?(json: [String: Any]) {
        guard let id = json["id"] as? Int else { return nil }
        
        let location = json["location"] as? [String: Any]
        let coordinates = location?["coordinates"] as? [Double]
        self.lat = coordinates?[0] ?? 0
        self.long = coordinates?[1] ?? 0
        self.id = "\(id)"
    }

func sceneKitCoordinate(relativeTo userLocation: CLLocation) -> SCNVector3 {
    let distance = location.distance(from: userLocation)
    let heading = userLocation.coordinate.getHeading(toPoint: location.coordinate)
    let headingRadians = heading * (.pi/180)
    
    let distanceScale: Double = 1/140
    let eastWestOffset = distance * sin(headingRadians) * distanceScale
    let northSouthOffset = distance * cos(headingRadians)  * distanceScale
    
    let altitudeScale: Double = 1/140 //1/20
    let upDownOffset: Double = 0//alt * altitudeScale

    return SCNVector3(eastWestOffset, upDownOffset, -northSouthOffset)
}
    
    var location: CLLocation {
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        return CLLocation(
            coordinate: coordinate,
            altitude: 0,
            horizontalAccuracy: 1,
            verticalAccuracy: 1,
            timestamp: Date()
        )
    }

}

// MARK: CLLocation Coordinate Heading

extension CLLocationCoordinate2D {
    
    func getHeading(toPoint point: CLLocationCoordinate2D) -> Double {
        func degreesToRadians(_ degrees: Double) -> Double { return degrees * .pi / 180.0 }
        func radiansToDegrees(_ radians: Double) -> Double { return radians * 180.0 / .pi }
        
        let lat1 = degreesToRadians(latitude)
        let lon1 = degreesToRadians(longitude)
        
        let lat2 = degreesToRadians(point.latitude);
        let lon2 = degreesToRadians(point.longitude);
        
        let dLon = lon2 - lon1;
        
        let y = sin(dLon) * cos(lat2);
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
        let radiansBearing = atan2(y, x);
        
        return radiansToDegrees(radiansBearing)
    }
}
