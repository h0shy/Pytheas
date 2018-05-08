//
//  Extensions.swift
//  Pytheas
//
//  Created by Stefan Hoschkara on 25.03.18.
//  Copyright © 2018 Stefan Hoschkara. All rights reserved.
//

import MapKit

extension MKPolyline {

    var pointAnnotations: [MKPointAnnotation] {
        
        var coordinates = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: pointCount)
        getCoordinates(&coordinates, range: NSRange(location: 0, length: pointCount))
        
        return coordinates.map {
            let point = MKPointAnnotation()
            point.coordinate = CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
            return point
        }
    }
}

extension MKPolygon {
    
    var pointAnnotations: [MKPointAnnotation] {
        
        var coordinates = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: pointCount)
        getCoordinates(&coordinates, range: NSRange(location: 0, length: pointCount))
        
        return coordinates.map {
            let point = MKPointAnnotation()
            point.coordinate = CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
            return point
        }
    }
}
