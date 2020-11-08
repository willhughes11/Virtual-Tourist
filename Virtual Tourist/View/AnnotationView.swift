//
//  AnnotationView.swift
//  Virtual Tourist
//
//  Created by William K Hughes on 11/5/20.
//

import Foundation
import MapKit

class AnnotationView: NSObject, MKAnnotation {
    let title: String? = nil
    let subtitle: String? = nil
    let coordinate: CLLocationCoordinate2D
    var pin: Pin
    
    init(coordinate: CLLocationCoordinate2D, pin: Pin){
        self.coordinate = coordinate
        self.pin = pin
        super.init()
    }
}
