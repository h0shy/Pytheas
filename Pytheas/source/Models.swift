//
//  Models.swift
//  Pytheas
//
//  Created by Stefan Hoschkara on 09.05.18.
//  Copyright © 2018 Stefan Hoschkara. All rights reserved.
//

import Foundation
import CoreLocation

public protocol Shape {
    
    var title: String? { get }
    var subtitle: String? { get }
}

struct Point: Shape {
    
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String? = nil, subtitle: String? = nil) {
        
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}

struct Line: Shape {
    
    let coordinates: [CLLocationCoordinate2D]
    let title: String?
    let subtitle: String?
    
    var points: [Point] { return coordinates.map { Point(coordinate: $0) } }
}

struct Polygon: Shape {
    
    let coordinates: [CLLocationCoordinate2D]
    let interiorPolygons: [Polygon]
    let title: String?
    let subtitle: String?
    
    var points: [Point] { return coordinates.map { Point(coordinate: $0) } }
}
