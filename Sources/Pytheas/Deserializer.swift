import Foundation
import CoreLocation

public final class Pytheas {

    enum DeserializeError: Swift.Error {
        case typeNotSupported
        case invalidCoordinatePair
        case polygonIsEmpty
        case noFeaturesFound
        case noPointCoordinatesFound
        case noLineCoordinatesFound
        case noPolygonCoordinatesFound
        case noMultiPointCoordinatesFound
        case noMultiLineCoordinatesFound
        case noMultiPolygonCoordinatesFound
    }
    
    public static func shape(from feature: [String: Any]) throws -> Any? {
        
        let type: String?
        if let geometry = feature[Key.geometry] as? [String: Any] {
            type = geometry[Key.type] as? String
        } else {
            type = feature[Key.type] as? String
        }
        
        switch type {
        case Value.Point: return try point(from: feature)
        case Value.LineString: return try lineString(from: feature)
        case Value.Polygon: return try polygon(from: feature)
        case Value.MultiPoint: return try multiPoint(from: feature)
        case Value.MultiLineString: return try multiLineString(from: feature)
        case Value.MultiPolygon: return try multiPolygon(from: feature)
        default: throw DeserializeError.typeNotSupported
        }
    }
    
    public static func shapes(from featureCollection: [String: Any]) throws -> [Any]? {
        
        assert(featureCollection[Key.type] as? String == Value.FeatureCollection)
        guard let features = featureCollection[Key.features] as? [[String: Any]] else { throw DeserializeError.noFeaturesFound }
        
        var shapes: [Any] = []
        for feature in features {
            guard let shape = try shape(from: feature) else { continue }
            if let subShapes = shape as? [Any] {
                shapes.append(contentsOf: subShapes)
            } else {
                shapes.append(shape)
            }
        }
        
        return shapes
    }
    
    private static func point(from feature:[String: Any]) throws -> Point? {
        
        guard let figures = unwrapCoordinates(from: feature) as? [Double],
              let coordinate = try coordinate(from: figures) else { throw DeserializeError.noPointCoordinatesFound }

        return Point(coordinate: coordinate,
                     title: title(from: feature[Key.properties] as? [String: Any]),
                     subtitle: subtitle(from: feature[Key.properties] as? [String: Any]))
    }
    
    private static func lineString(from feature:[String: Any]) throws -> Line? {
        
        guard let pairs = unwrapCoordinates(from: feature) as? [[Double]] else { throw DeserializeError.noLineCoordinatesFound }
        assert(pairs.count >= 2, "Line needs at least two points.")
        
        return Line(coordinates: try pairs.compactMap { try coordinate(from: $0) },
                    title: title(from: feature[Key.properties] as? [String: Any]),
                    subtitle: subtitle(from: feature[Key.properties] as? [String: Any]))
    }
    
    private static func polygon(from feature:[String: Any]) throws -> Polygon? {
        
        guard let sets = unwrapCoordinates(from: feature) as? [[[Double]]] else { throw DeserializeError.noPolygonCoordinatesFound }

        var all: [Polygon] = []
        for pairs in sets {
            
            let polygon = Polygon(coordinates: try pairs.compactMap { try coordinate(from: $0) },
                                  interiorPolygons: [],
                                  title: title(from: feature[Key.properties] as? [String: Any]),
                                  subtitle: subtitle(from: feature[Key.properties] as? [String: Any]))
            all.append(polygon)
        }
        
        let polygon: Polygon
        switch all.count {
        case 0: throw DeserializeError.polygonIsEmpty
        case 1: polygon = all.first!
        default:
            let exterior = all.first!
            let interiors = Array(all[1...all.count-1])
            polygon = Polygon(coordinates: exterior.coordinates,
                              interiorPolygons: interiors,
                              title: title(from: feature[Key.properties] as? [String: Any]),
                              subtitle: subtitle(from: feature[Key.properties] as? [String: Any]))
        }
        
        return polygon
    }
    
    private static func multiPoint(from feature:[String: Any]) throws -> [Point]? {
        
        guard let pairs = unwrapCoordinates(from: feature) as? [[Double]] else { throw DeserializeError.noMultiPointCoordinatesFound }
        let properties = feature[Key.properties] as? [String: Any]
        
        var points: [Point?] = []

        for pair in pairs {
            var subFeature: [String: Any] = [:]
            subFeature[Key.type] = Value.Feature
            
            var subGeometry: [String: Any] = [:]
            subGeometry[Key.type] = Value.Point
            subGeometry[Key.coordinates] = pair
            
            subFeature[Key.geometry] = subGeometry
            subFeature[Key.properties] = properties
 
            points.append(try point(from: subFeature))
        }
        
        return points.compactMap {$0}
    }
    
    private static func multiLineString(from feature:[String: Any]) throws -> [Line]? {
        
        guard let sets = unwrapCoordinates(from: feature) as? [[[Double]]] else { throw DeserializeError.noMultiLineCoordinatesFound }
        let properties = feature[Key.properties] as? [String: Any]
        
        var lines: [Line?] = []
        
        for set in sets {
            var subFeature: [String: Any] = [:]
            subFeature[Key.type] = Value.Feature
            
            var subGeometry: [String: Any] = [:]
            subGeometry[Key.type] = Value.LineString
            subGeometry[Key.coordinates] = set
            
            subFeature[Key.geometry] = subGeometry
            subFeature[Key.properties] = properties
            
            lines.append(try lineString(from: subFeature))
        }
        
        return lines.compactMap {$0}
    }
    
    private static func multiPolygon(from feature:[String: Any]) throws -> [Polygon]? {
        
        guard let groups = unwrapCoordinates(from: feature) as? [[[[Double]]]] else { throw DeserializeError.noMultiPolygonCoordinatesFound }
        let properties = feature[Key.properties] as? [String: Any]
        
        var polygons: [Polygon?] = []

        for group in groups {
            var subFeature: [String: Any] = [:]
            subFeature[Key.type] = Value.Feature
            
            var subGeometry: [String: Any] = [:]
            subGeometry[Key.type] = Value.Polygon
            subGeometry[Key.coordinates] = group
            
            subFeature[Key.geometry] = subGeometry
            subFeature[Key.properties] = properties
            
            polygons.append(try polygon(from: subFeature))
        }
        
        return polygons.compactMap {$0}
    }
    
    // MARK: - Helper
    
    private static func coordinate(from coordinates: [Double]) throws -> CLLocationCoordinate2D? {
        guard coordinates.count == 2,
            let longitude = coordinates.first,
            let latitude = coordinates.last else { throw DeserializeError.invalidCoordinatePair }
        
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    private static func title(from properties: [String: Any]?) -> String? {
        return properties?[Key.title] as? String
    }
    
    private static func subtitle(from properties: [String: Any]?) -> String? {
        return properties?[Key.subtitle] as? String
    }
    
    private static func unwrapCoordinates(from feature: [String: Any]) -> Any? {
        return (feature[Key.geometry] as? [String: Any])?[Key.coordinates] ?? feature[Key.coordinates]
    }
}
