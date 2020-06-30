import Foundation

extension Pytheas {
    
    public static func geoJson(from shape: Shape, properties: [String:Any]) -> [String:Any]? {
        
        var featureJson: [String:Any] = [:]
        
        let geometryJson: [String:Any]?
        switch shape {
        case let point as Point: geometryJson = Pytheas.geoJSON(from: point)
        case let line as Line: geometryJson = Pytheas.geoJSON(from: line)
        case let polygon as Polygon: geometryJson = Pytheas.geoJSON(from: polygon)
        default: return nil
        }
        
        featureJson[Key.type] = Value.Feature
        featureJson[Key.geometry] = geometryJson
        featureJson[Key.properties] = properties
        
        return featureJson
    }
    
    public static func geoJson(from shapes: [Shape], properties: [[String:Any]]) -> [String:Any]? {
        
        guard shapes.count == properties.count else { return nil }
        
        var featuresJson: [String:Any] = [:]
        var features: [[String:Any]?] = []
        
        for (index, shape) in shapes.enumerated() {
            features.append(Pytheas.geoJson(from: shape, properties: properties[index]))
        }
        
        featuresJson[Key.type] = Value.FeatureCollection
        featuresJson[Key.features] = features.compactMap { $0 }
        
        return featuresJson
    }
    
    private static func geoJSON(from point: Point) -> [String:Any]? {
        
        var pointJson: [String:Any] = [:]
        pointJson[Key.type] = Value.Point
        pointJson[Key.coordinates] = [point.coordinate.longitude, point.coordinate.latitude]
        
        return pointJson
    }

    private static func geoJSON(from line: Line) -> [String:Any]? {
        
        assert(line.points.count >= 2, "Line needs at least two points.")
        
        var pointsJson: [String:Any] = [:]
        pointsJson[Key.type] = Value.LineString
        pointsJson[Key.coordinates] = line.points.compactMap { Pytheas.geoJSON(from: $0) }.map { $0[Key.coordinates]}
        
        return pointsJson
    }
    
    private static func geoJSON(from polygon: Polygon) -> [String:Any]? {
        
        assert(polygon.points.count >= 3, "Line needs at least three points.")

        var polygonJson: [String:Any] = [:]
        var sets: [Any] = []
        var polygons = [polygon]
        
        polygons.append(contentsOf: polygon.interiorPolygons)
        
        for polygon in polygons {
            sets.append(polygon.points.compactMap { Pytheas.geoJSON(from: $0) }.map { $0[Key.coordinates]} )
        }
        
        polygonJson[Key.type] = Value.Polygon
        polygonJson[Key.coordinates] = sets
        
        return polygonJson
    }
}
