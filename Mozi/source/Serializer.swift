//
//  Serializer.swift
//  Mozi
//
//  Created by Stefan Hoschkara on 29.03.18.
//  Copyright © 2018 Stefan Hoschkara. All rights reserved.
//

import Foundation
import MapKit

extension Mozi {
    
    public static func geoJson(from shape: MKShape, properties: [String:Any]) -> [String:Any]? {
        
        var featureJson: [String:Any] = [:]
        
        let geometryJson: [String:Any]?
        switch shape {
        case let point as MKPointAnnotation: geometryJson = Mozi.geoJSON(from: point)
        case let line as MKPolyline: geometryJson = Mozi.geoJSON(from: line)
        case let polygon as MKPolygon: geometryJson = Mozi.geoJSON(from: polygon)
        default: return nil
        }
        
        featureJson[Key.type] = Value.Feature
        featureJson[Key.geometry] = geometryJson
        featureJson[Key.properties] = properties
        
        return featureJson
    }
    
    public static func geoJson(from shapes: [MKShape], properties: [[String:Any]]) -> [String:Any]? {
        
        guard shapes.count == properties.count else { return nil }
        
        var featuresJson: [String:Any] = [:]
        var features: [[String:Any]?] = []
        
        for (index, shape) in shapes.enumerated() {
            features.append(Mozi.geoJson(from: shape, properties: properties[index]))
        }
        
        featuresJson[Key.type] = Value.FeatureCollection
        featuresJson[Key.features] = features.compactMap { $0 }
        
        return featuresJson
    }
    
    private static func geoJSON(from point: MKPointAnnotation) -> [String:Any]? {
        
        var pointJson: [String:Any] = [:]
        pointJson[Key.type] = Value.Point
        pointJson[Key.coordinates] = [point.coordinate.latitude, point.coordinate.longitude]
        
        return pointJson
    }

    private static func geoJSON(from line: MKPolyline) -> [String:Any]? {
        
        var pointsJson: [String:Any] = [:]
        pointsJson[Key.type] = Value.LineString
        pointsJson[Key.coordinates] = line.pointAnnotations.compactMap { Mozi.geoJSON(from: $0) }.map { $0[Key.coordinates]}
        
        return pointsJson
    }
    
    private static func geoJSON(from polygon: MKPolygon) -> [String:Any]? {
        
        var polygonJson: [String:Any] = [:]
        var sets: [Any] = []
        var polygons = [polygon]
        
        if let interiors = polygon.interiorPolygons {
            polygons.append(contentsOf: interiors)
        }
        
        for polygon in polygons {
            sets.append(polygon.pointAnnotations.compactMap { Mozi.geoJSON(from: $0) }.map { $0[Key.coordinates]} )
        }
        
        polygonJson[Key.type] = Value.Polygon
        polygonJson[Key.coordinates] = sets
        
        return polygonJson
    }
}
