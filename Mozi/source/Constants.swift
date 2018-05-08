//
//  Constants.swift
//  Mozi
//
//  Created by Stefan Hoschkara on 04.05.18.
//  Copyright © 2018 Stefan Hoschkara. All rights reserved.
//

import Foundation

struct Key {
    
    static let features = "features"
    static let type = "type"
    static let geometry = "geometry"
    static let coordinates = "coordinates"
    static let properties = "properties"
    static let title = "title"
    static let subtitle = "subtitle"
}

struct Value {
    
    static let Feature = "Feature"
    static let Point = "Point"
    static let LineString = "LineString"
    static let Polygon = "Polygon"
    static let MultiPoint = "MultiPoint"
    static let MultiLineString = "MultiLineString"
    static let MultiPolygon = "MultiPolygon"
    static let FeatureCollection = "FeatureCollection"
}

struct Fixture {
    
    static let FeatureCollection = "FeatureCollection"
    static let LineString = "LineString"
    static let LineStringInGeometry = "LineStringInGeometry"
    static let MultiLineString = "MultiLineString"
    static let MultiLineStringInGeometry = "MultiLineStringInGeometry"
    static let MultiPoint = "MultiPoint"
    static let MultiPointInGeometry = "MultiPointInGeometry"
    static let MultiPolygon = "MultiPolygon"
    static let MultiPolygonInGeometry = "MultiPolygonInGeometry"
    static let Point = "Point"
    static let PointInGeometry = "PointInGeometry"
    static let Polygon = "Polygon"
    static let PolygonInGeometry = "PolygonInGeometry"
    static let PolygonWithHoles = "PolygonWithHoles"
    static let PolygonWithHolesInGeometry = "PolygonWithHolesInGeometry"
}
