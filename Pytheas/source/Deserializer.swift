//
//  Deserializer.swift
//  Pytheas
//
//  Created by Stefan Hoschkara on 21.03.18.
//  Copyright © 2018 Stefan Hoschkara. All rights reserved.
//

import Foundation
import MapKit

public final class Pytheas {
    
    public static func shape(from feature: [String:Any]) -> Any? {
        
        let type: String?
        if let geometry = feature[Key.geometry] as? [String:Any] {
            type = geometry[Key.type] as? String
        } else {
            type = feature[Key.type] as? String
        }
        
        switch type {
        case Value.Point: return Pytheas.point(from: feature)
        case Value.LineString: return Pytheas.lineString(from: feature)
        case Value.Polygon: return Pytheas.polygon(from: feature)
        case Value.MultiPoint: return Pytheas.multiPoint(from: feature)
        case Value.MultiLineString: return Pytheas.multiLineString(from: feature)
        case Value.MultiPolygon: return Pytheas.multiPolygon(from: feature)
        default: return nil
        }
    }
    
    public static func shapes(from featureCollection: [String:Any]) -> [Any]? {
        
        assert(featureCollection[Key.type] as? String == Value.FeatureCollection)
        guard let features = featureCollection[Key.features] as? [[String:Any]] else { return nil }
        
        var shapes: [Any] = []
        for feature in features {
            guard let shape =  Pytheas.shape(from: feature) else { continue }
            if let subShapes = shape as? [Any] {
                shapes.append(contentsOf: subShapes)
            } else {
                shapes.append(shape)
            }
        }
        
        return shapes
    }
    
    private static func point(from feature:[String:Any]) -> MKPointAnnotation? {
        
        guard let figures = Pytheas.unwrapCoordinates(from: feature) as? [Double],
              let coordinate = coordinate(from: figures) else { return nil }

        let point = MKPointAnnotation()
        point.coordinate = coordinate
        add(properties: feature[Key.properties] as? [String:Any], to: point)
        
        return point
    }
    
    private static func coordinate(from coordinates: [Double]) -> CLLocationCoordinate2D? {
        
        guard coordinates.count == 2,
              let latitude = coordinates.first,
              let longitude = coordinates.last else { return nil }
        
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    private static func lineString(from feature:[String:Any]) -> MKPolyline? {
        
        guard let pairs = Pytheas.unwrapCoordinates(from: feature) as? [[Double]] else { return nil }
        
        var coordinates = pairs.compactMap { Pytheas.coordinate(from: $0) }
        let polyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)
        add(properties: feature[Key.properties] as? [String:Any], to: polyline)
        
        return polyline
    }
    
    private static func polygon(from feature:[String:Any]) -> MKPolygon? {
        
        guard let sets = Pytheas.unwrapCoordinates(from: feature) as? [[[Double]]] else { return nil }
        
        var polygons: [MKPolygon] = []
        for pairs in sets {
            
            var coordinates = pairs.compactMap { Pytheas.coordinate(from: $0) }
            let polygon = MKPolygon(coordinates: &coordinates, count: coordinates.count)
            polygons.append(polygon)
        }
        
        let polygon: MKPolygon
        switch polygons.count {
        case 0: return nil
        case 1: polygon = polygons.first!
        default:
            let exterior = polygons.first!
            let interiors = Array(polygons[1...polygons.count-1])
            polygon = MKPolygon(points: exterior.points(), count: exterior.pointCount, interiorPolygons: interiors)
        }
        
        add(properties: feature[Key.properties] as? [String:Any], to: polygon)
        
        return polygon
    }
    
    private static func multiPoint(from feature:[String:Any]) -> [MKPointAnnotation]? {
        
        guard let pairs = Pytheas.unwrapCoordinates(from: feature) as? [[Double]] else { return nil }
        let properties = feature[Key.properties] as? [String:Any]
        
        var points: [MKPointAnnotation?] = []

        for pair in pairs {
            var subFeature: [String:Any] = [:]
            subFeature[Key.type] = Value.Feature
            
            var subGeometry: [String:Any] = [:]
            subGeometry[Key.type] = Value.Point
            subGeometry[Key.coordinates] = pair
            
            subFeature[Key.geometry] = subGeometry
            subFeature[Key.properties] = properties
 
            points.append(point(from: subFeature))
        }
        
        return points.compactMap {$0}
    }
    
    private static func multiLineString(from feature:[String:Any]) -> [MKPolyline]? {
        
        guard let sets = Pytheas.unwrapCoordinates(from: feature) as? [[[Double]]] else { return nil }
        let properties = feature[Key.properties] as? [String:Any]
        
        var lines: [MKPolyline?] = []
        
        for set in sets {
            var subFeature: [String:Any] = [:]
            subFeature[Key.type] = Value.Feature
            
            var subGeometry: [String:Any] = [:]
            subGeometry[Key.type] = Value.LineString
            subGeometry[Key.coordinates] = set
            
            subFeature[Key.geometry] = subGeometry
            subFeature[Key.properties] = properties
            
            lines.append(lineString(from: subFeature))
        }
        
        return lines.compactMap {$0}
    }
    
    private static func multiPolygon(from feature:[String:Any]) -> [MKPolygon]? {
        
        guard let groups = Pytheas.unwrapCoordinates(from: feature) as? [[[[Double]]]] else { return nil }
        let properties = feature[Key.properties] as? [String:Any]
        
        var polygons: [MKPolygon?] = []

        for group in groups {
            var subFeature: [String:Any] = [:]
            subFeature[Key.type] = Value.Feature
            
            var subGeometry: [String:Any] = [:]
            subGeometry[Key.type] = Value.Polygon
            subGeometry[Key.coordinates] = group
            
            subFeature[Key.geometry] = subGeometry
            subFeature[Key.properties] = properties
            
            polygons.append(polygon(from: subFeature))
        }
        
        return polygons.compactMap {$0}
    }
    
    // MARK: - Helper
    
    private static func add(properties: [String:Any]?, to shape: MKShape)  {
        
        shape.title = properties?[Key.title] as? String
        shape.subtitle = properties?[Key.subtitle] as? String
    }
    
    private static func unwrapCoordinates(from feature: [String:Any]) -> Any? {
        
        return (feature[Key.geometry] as? [String:Any])?[Key.coordinates] ?? feature[Key.coordinates]
    }
}
