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

public struct Point: Shape {
    
    public let coordinate: CLLocationCoordinate2D
    public let title: String?
    public let subtitle: String?
    
    public init(coordinate: CLLocationCoordinate2D, title: String? = nil, subtitle: String? = nil) {
        
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}

public struct Line: Shape {
    
    public let coordinates: [CLLocationCoordinate2D]
    public let title: String?
    public let subtitle: String?

    public init(coordinates: [CLLocationCoordinate2D], title: String? = nil, subtitle: String? = nil) {

        self.coordinates = coordinates
        self.title = title
        self.subtitle = subtitle
    }
    
    public var points: [Point] { return coordinates.map { Point(coordinate: $0) } }
}

public struct Polygon: Shape {
    
    public let coordinates: [CLLocationCoordinate2D]
    public let interiorPolygons: [Polygon]
    public let title: String?
    public let subtitle: String?

    public init(coordinates: [CLLocationCoordinate2D], interiorPolygons: [Polygon], title: String? = nil, subtitle: String? = nil) {

        self.coordinates = coordinates
        self.interiorPolygons = interiorPolygons
        self.title = title
        self.subtitle = subtitle
    }
    
    public var points: [Point] { return coordinates.map { Point(coordinate: $0) } }
}
