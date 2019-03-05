//
//  Notification.swift
//  bert8270_final
//
//  Created by Tudor Bertiean on 2018-03-21.
//  Copyright © 2018 wlu. All rights reserved.
//

import Foundation
import os
import MapKit
import CoreLocation

class Notification: NSObject, NSCoding, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var radius: CLLocationDistance
    
    private var message: String
    private var location: String
    private var on: Bool
    
    init?(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance, message: String, on: Bool, location: String){
        guard !message.isEmpty else {
            return nil
        }
        
        self.message = message
        self.coordinate = coordinate
        self.radius = radius
        self.on = on
        self.location = location
    }
    
    // Create the region with the information from notification item.
    func getRegion() -> CLCircularRegion {
        let region = CLCircularRegion(center: self.coordinate, radius: self.radius, identifier: self.message)
        // We want the notifications only on enter
        region.notifyOnExit = false
        region.notifyOnEntry = true
        return region
    }
    
    // Turn on the coordinate tracking of the user
    func startMonitoring(locationManager: CLLocationManager, viewcontroller: UIViewController) {
        let region = self.getRegion()
        locationManager.startMonitoring(for: region)
    }
    
    func stopMonitoring(locationManager: CLLocationManager) {
        for region in locationManager.monitoredRegions {
            guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == self.message else { continue }
            locationManager.stopMonitoring(for: circularRegion)
        }
    }
    
    func getMessage() -> String {
        return self.message
    }
    
    func setMessage(message: String) {
        self.message = message
    }
    
    func getLocation() -> String {
        return self.location
    }
    
    func setLocation(location: String) {
        self.location = location
    }
    
    func isOn() -> Bool {
        return self.on
    }
    
    func setOn(on: Bool, locationManager: CLLocationManager, viewcontroller: UIViewController) {
        self.on = on
        if on == false {
            self.stopMonitoring(locationManager: locationManager)
        } else {
            self.startMonitoring(locationManager: locationManager, viewcontroller: viewcontroller)
        }
    }
    
    func getCoordinate() -> CLLocationCoordinate2D {
        return self.coordinate
    }
    
    func setCoordinate(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    func getRadius() -> CLLocationDistance {
        return self.radius
    }
    
    func setRadius(radius: CLLocationDistance) {
        self.radius = radius
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.message, forKey: PropertyKey.message)
        aCoder.encode(coordinate.latitude, forKey: PropertyKey.latitude)
        aCoder.encode(coordinate.longitude, forKey: PropertyKey.longitude)
        aCoder.encode(radius, forKey: PropertyKey.radius)
        aCoder.encode(self.on, forKey: PropertyKey.on)
        aCoder.encode(self.location, forKey: PropertyKey.location)
    } //encode
    
    required convenience init?(coder aDecoder: NSCoder) {
        // The question is required. If we cannot decode a question string, the initializer should fail
        let message = aDecoder.decodeObject(forKey: PropertyKey.message) as? String
        let latitude = aDecoder.decodeDouble(forKey: PropertyKey.latitude)
        let longitude = aDecoder.decodeDouble(forKey: PropertyKey.longitude)
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let radius = aDecoder.decodeDouble(forKey: PropertyKey.radius)
        let on = aDecoder.decodeBool(forKey: PropertyKey.on)
        let location = aDecoder.decodeObject(forKey: PropertyKey.location) as? String
        self.init(coordinate: coordinate, radius: radius, message: message!, on: on, location: location!)
    } // decode

    
}// Card
struct PropertyKey {
    static let message = "message"
    static let latitude = "latitude"
    static let longitude = "longitude"
    static let radius = "radius"
    static let on = "on"
    static let location = "location"
}
