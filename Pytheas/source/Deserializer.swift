//
//  Deserializer.swift
//  Pytheas
//
//  Created by Stefan Hoschkara on 21.03.18.
//  Copyright © 2018 Stefan Hoschkara. All rights reserved.
//

import Foundation
import CoreLocation

public final class Pytheas {
    
    public static func shape(from feature: [String:Any]) -> Any? {
        
        let type: String?
        if let geometry = feature[Key.geometry] as? [String:Any] {
            type = geometry[Key.type] as? String
        } else {
            type = feature[Key.type] as? String
        }
        
        switch type {
        case Value.Point: return point(from: feature)
        case Value.LineString: return lineString(from: feature)
        case Value.Polygon: return polygon(from: feature)
        case Value.MultiPoint: return multiPoint(from: feature)
        case Value.MultiLineString: return multiLineString(from: feature)
        case Value.MultiPolygon: return multiPolygon(from: feature)
        default: return nil
        }
    }
    
    public static func shapes(from featureCollection: [String:Any]) -> [Any]? {
        
        assert(featureCollection[Key.type] as? String == Value.FeatureCollection)
        guard let features = featureCollection[Key.features] as? [[String:Any]] else { return nil }
        
        var shapes: [Any] = []
        for feature in features {
            guard let shape =  shape(from: feature) else { continue }
            if let subShapes = shape as? [Any] {
                shapes.append(contentsOf: subShapes)
            } else {
                shapes.append(shape)
            }
        }
        
        return shapes
    }
    
    private static func point(from feature:[String:Any]) -> Point? {
        
        guard let figures = unwrapCoordinates(from: feature) as? [Double],
              let coordinate = coordinate(from: figures) else { return nil }

        return Point(coordinate: coordinate,
                     title: title(from: feature[Key.properties] as? [String:Any]),
                     subtitle: subtitle(from: feature[Key.properties] as? [String:Any]))
    }
    
    private static func lineString(from feature:[String:Any]) -> Line? {
        
        guard let pairs = unwrapCoordinates(from: feature) as? [[Double]] else { return nil }
        assert(pairs.count >= 2, "Line needs at least two points.")
        
        return Line(coordinates: pairs.compactMap { coordinate(from: $0) },
                    title: title(from: feature[Key.properties] as? [String:Any]),
                    subtitle: subtitle(from: feature[Key.properties] as? [String:Any]))
    }
    
    private static func polygon(from feature:[String:Any]) -> Polygon? {
        
        guard let sets = unwrapCoordinates(from: feature) as? [[[Double]]] else { return nil }

        var all: [Polygon] = []
        for pairs in sets {
            
            let polygon = Polygon(coordinates: pairs.compactMap { coordinate(from: $0) },
                                  interiorPolygons: [],
                                  title: title(from: feature[Key.properties] as? [String:Any]),
                                  subtitle: subtitle(from: feature[Key.properties] as? [String:Any]))
            all.append(polygon)
        }
        
        let polygon: Polygon
        switch all.count {
        case 0: return nil
        case 1: polygon = all.first!
        default:
            let exterior = all.first!
            let interiors = Array(all[1...all.count-1])
            polygon = Polygon(coordinates: exterior.coordinates,
                              interiorPolygons: interiors,
                              title: title(from: feature[Key.properties] as? [String:Any]),
                              subtitle: subtitle(from: feature[Key.properties] as? [String:Any]))
        }
        
        return polygon
    }
    
    private static func multiPoint(from feature:[String:Any]) -> [Point]? {
        
        guard let pairs = unwrapCoordinates(from: feature) as? [[Double]] else { return nil }
        let properties = feature[Key.properties] as? [String:Any]
        
        var points: [Point?] = []

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
    
    private static func multiLineString(from feature:[String:Any]) -> [Line]? {
        
        guard let sets = unwrapCoordinates(from: feature) as? [[[Double]]] else { return nil }
        let properties = feature[Key.properties] as? [String:Any]
        
        var lines: [Line?] = []
        
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
    
    private static func multiPolygon(from feature:[String:Any]) -> [Polygon]? {
        
        guard let groups = unwrapCoordinates(from: feature) as? [[[[Double]]]] else { return nil }
        let properties = feature[Key.properties] as? [String:Any]
        
        var polygons: [Polygon?] = []

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
    
    private static func coordinate(from coordinates: [Double]) -> CLLocationCoordinate2D? {
        
        guard coordinates.count == 2,
            let longitude = coordinates.first,
            let latitude = coordinates.last else { return nil }
        
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    private static func title(from properties: [String:Any]?) -> String? {
        return properties?[Key.title] as? String
    }
    
    private static func subtitle(from properties: [String:Any]?) -> String? {
        return properties?[Key.subtitle] as? String
    }
    
    private static func unwrapCoordinates(from feature: [String:Any]) -> Any? {
        
        return (feature[Key.geometry] as? [String:Any])?[Key.coordinates] ?? feature[Key.coordinates]
    }
}
