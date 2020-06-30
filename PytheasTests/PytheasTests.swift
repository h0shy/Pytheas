import Quick
import Nimble
@testable import Pytheas

final class PytheasTests: QuickSpec {

    override func spec() {
        
        let longitudeIndex = 0
        let latitudeIndex = 1
        let outerPolygonIndex = 0
        
        func jsonFromFixture(_ name: String) -> [String:Any] {
            let defaultBundle = Bundle(for: type(of: self))
            let defaultPath = defaultBundle.path(forResource: name, ofType: "geojson")!
            let url = URL(fileURLWithPath: defaultPath)
            let jsonData = try! Data.init(contentsOf: url, options: .mappedIfSafe)

            do {
                guard let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String:Any] else  {
                    fail("Could not find fixture \(name) in \(jsonData) with url: \(url)")
                    return [:]
                }
                return json
            } catch {
                print("Error \(error) while deserializing \(name).")
            }
            return [:]
        }
        
        func properties(from shape: Shape) -> [String:Any] {
            
            var properties: [String:Any] = [:]
            properties[Key.title] = shape.title
            properties[Key.subtitle] = shape.subtitle
            
            return properties
        }
        
        describe("Pytheas") {
            
            context("handles points") {
                
                it("deserializes directly") {
                    
                    let json = jsonFromFixture(Fixture.Point)
                    guard let point = Pytheas.shape(from: json) as? Point else {
                        fail("Could not deserialize point.")
                        return
                    }
                    expect(point.coordinate.latitude) == (json[Key.coordinates] as? [Double])?[latitudeIndex]
                    expect(point.coordinate.longitude) == (json[Key.coordinates] as? [Double])?[longitudeIndex]
                }
                
                it("deserializes and serializes in geometry") {
                    
                    let json = jsonFromFixture(Fixture.PointInGeometry)
                    guard let point = Pytheas.shape(from: json) as? Point else {
                        fail("Could not deserialize point.")
                        return
                    }
                    guard let serialized = Pytheas.geoJson(from: point, properties: properties(from: point)) else {
                        fail("Could not serialize point.")
                        return
                    }
                    
                    expect(point.title) == (serialized[Key.properties] as? [String:Any])?[Key.title] as? String
                    expect(point.subtitle) == (serialized[Key.properties] as? [String:Any])?[Key.subtitle] as? String
                    
                    expect(point.coordinate.latitude) == ((json[Key.geometry] as? [String:Any])?[Key.coordinates] as? [Double])?[latitudeIndex]
                    expect(point.coordinate.longitude) == ((json[Key.geometry] as? [String:Any])?[Key.coordinates] as? [Double])?[longitudeIndex]
                    expect(point.title) == (json[Key.properties] as? [String:Any])?[Key.title] as? String
                    expect(point.subtitle) == (json[Key.properties] as? [String:Any])?[Key.subtitle] as? String

                    expect(point.coordinate.latitude) == ((serialized[Key.geometry] as? [String:Any])?[Key.coordinates] as? [Double])?[latitudeIndex]
                    expect(point.coordinate.longitude) == ((serialized[Key.geometry] as? [String:Any])?[Key.coordinates] as? [Double])?[longitudeIndex]
                }
            }
            
            context("handes lines") {
                
                it("deserializes directly") {

                    let json = jsonFromFixture(Fixture.LineString)
                    guard let line = Pytheas.shape(from: json) as? Line else {
                        fail("Could not deserialize line.")
                        return
                    }

                    expect(line.points.count) == (json[Key.coordinates] as? [[Double]])?.count
                    for (pointIndex, point) in line.points.enumerated() {
                        expect(String(format: "%.0f", point.coordinate.latitude)) == String(format: "%.0f", (json[Key.coordinates] as? [[Double]])?[pointIndex][latitudeIndex].rounded(.toNearestOrEven) ?? "")
                        expect(String(format: "%.0f", point.coordinate.longitude)) == String(format: "%.0f", (json[Key.coordinates] as? [[Double]])?[pointIndex][longitudeIndex].rounded(.toNearestOrEven) ?? "")
                    }
                }
            
                it("deserializes and serializes in geometry") {

                    let json = jsonFromFixture(Fixture.LineStringInGeometry)
                    guard let line = Pytheas.shape(from: json) as? Line else {
                        fail("Could not deserialize line.")
                        return
                    }
                    guard let serialized = Pytheas.geoJson(from: line, properties: properties(from: line)) else {
                        fail("Could not serialize line.")
                        return
                    }
                    
                    expect(line.title) == (json[Key.properties] as? [String:Any])?[Key.title] as? String
                    expect(line.subtitle) == (json[Key.properties] as? [String:Any])?[Key.subtitle] as? String
                    
                    expect(line.points.count) == ((json[Key.geometry] as? [String:Any])?[Key.coordinates] as? [[Double]])?.count
                    for (pointIndex, point) in line.points.enumerated() {
                        
                        expect(String(format: "%.0f", point.coordinate.latitude)) == String(format: "%.0f", ((json[Key.geometry] as? [String:Any])?[Key.coordinates] as? [[Double]])?[pointIndex][latitudeIndex].rounded(.toNearestOrEven) ?? "")
                        expect(String(format: "%.0f", point.coordinate.longitude)) == String(format: "%.0f", ((json[Key.geometry] as? [String:Any])?[Key.coordinates] as? [[Double]])?[pointIndex][longitudeIndex].rounded(.toNearestOrEven) ?? "")
                        
                        expect(String(format: "%.0f", point.coordinate.latitude)) == String(format: "%.0f", ((serialized[Key.geometry] as? [String:Any])?[Key.coordinates] as? [[Double]])?[pointIndex][latitudeIndex].rounded(.toNearestOrEven) ?? "")
                        expect(String(format: "%.0f", point.coordinate.longitude)) == String(format: "%.0f", ((serialized[Key.geometry] as? [String:Any])?[Key.coordinates] as? [[Double]])?[pointIndex][longitudeIndex].rounded(.toNearestOrEven) ?? "")
                    }
                }
            }
            
            context("handles polygon") {
                
                it("deserializes directly") {
                    
                    let json = jsonFromFixture(Fixture.Polygon)
                    guard let polygon = Pytheas.shape(from: json) as? Polygon else {
                        fail("Could not deserialize polygon.")
                        return
                    }
                    
                    expect(polygon.points.count) == (json[Key.coordinates] as? [[[Double]]])?[outerPolygonIndex].count
                    for (pointIndex, point) in polygon.points.enumerated() {
                        expect(String(format: "%.0f", point.coordinate.latitude)) == String(format: "%.0f", (json[Key.coordinates] as? [[[Double]]])?[outerPolygonIndex][pointIndex][latitudeIndex].rounded(.toNearestOrEven) ?? "")
                        expect(String(format: "%.0f", point.coordinate.longitude)) == String(format: "%.0f", (json[Key.coordinates] as? [[[Double]]])?[outerPolygonIndex][pointIndex][longitudeIndex].rounded(.toNearestOrEven) ?? "")
                    }
                }
                
                it("deserializes and serializes in geometry") {
                    
                    let json = jsonFromFixture(Fixture.PolygonInGeometry)
                    guard let polygon = Pytheas.shape(from: json) as? Polygon else {
                        fail("Could not deserialize polygon.")
                        return
                    }
                    
                    guard let serialized = Pytheas.geoJson(from: polygon, properties: properties(from: polygon)) else {
                        fail("Could not serialize polygon.")
                        return
                    }
                    
                    expect(polygon.title) == (json[Key.properties] as? [String:Any])?[Key.title] as? String
                    expect(polygon.subtitle) == (json[Key.properties] as? [String:Any])?[Key.subtitle] as? String
                    
                    expect(polygon.points.count) == ((json[Key.geometry] as? [String:Any])?[Key.coordinates] as? [[[Double]]])?[outerPolygonIndex].count
                    for (pointIndex, point) in polygon.points.enumerated() {
                        expect(String(format: "%.0f", point.coordinate.latitude)) == String(format: "%.0f", ((json[Key.geometry] as? [String:Any])?[Key.coordinates] as? [[[Double]]])?[outerPolygonIndex][pointIndex][latitudeIndex].rounded(.toNearestOrEven) ?? "")
                        expect(String(format: "%.0f", point.coordinate.longitude)) == String(format: "%.0f", ((json[Key.geometry] as? [String:Any])?[Key.coordinates] as? [[[Double]]])?[outerPolygonIndex][pointIndex][longitudeIndex].rounded(.toNearestOrEven) ?? "")
                        
                        expect(String(format: "%.0f", point.coordinate.latitude)) == String(format: "%.0f", ((serialized[Key.geometry] as? [String:Any])?[Key.coordinates] as? [[[Double]]])?[outerPolygonIndex][pointIndex][latitudeIndex].rounded(.toNearestOrEven) ?? "")
                        expect(String(format: "%.0f", point.coordinate.longitude)) == String(format: "%.0f", ((serialized[Key.geometry] as? [String:Any])?[Key.coordinates] as? [[[Double]]])?[outerPolygonIndex][pointIndex][longitudeIndex].rounded(.toNearestOrEven) ?? "")
                    }
                }
            }
            
            context("handles polygon with holes") {
                
                it("deserializes directly") {
                    
                    let json = jsonFromFixture(Fixture.PolygonWithHoles)
                    guard let polygon = Pytheas.shape(from: json) as? Polygon else {
                        fail("Could not deserialize polygon.")
                        return
                    }
                    
                    expect(polygon.points.count) == (json[Key.coordinates] as? [[[Double]]])?[outerPolygonIndex].count
                    for (pointIndex, point) in polygon.points.enumerated() {
                        expect(String(format: "%.0f", point.coordinate.latitude)) == String(format: "%.0f", (json[Key.coordinates] as? [[[Double]]])?[outerPolygonIndex][pointIndex][latitudeIndex].rounded(.toNearestOrEven) ?? "")
                        expect(String(format: "%.0f", point.coordinate.longitude)) == String(format: "%.0f", (json[Key.coordinates] as? [[[Double]]])?[outerPolygonIndex][pointIndex][longitudeIndex].rounded(.toNearestOrEven) ?? "")
                    }

                    expect(polygon.interiorPolygons.count+1) == (json[Key.coordinates] as? [[[Double]]])?.count
                    for (interiorIndex, interior) in polygon.interiorPolygons.enumerated() {
                        expect(interior.points.count) == (json[Key.coordinates] as? [[[Double]]])?[interiorIndex+1].count
                        for (pointIndex, point) in interior.points.enumerated() {
                            expect(String(format: "%.0f", point.coordinate.latitude)) == String(format: "%.0f", (json[Key.coordinates] as? [[[Double]]])?[interiorIndex+1][pointIndex][latitudeIndex].rounded(.toNearestOrEven) ?? "")
                            expect(String(format: "%.0f", point.coordinate.longitude)) == String(format: "%.0f", (json[Key.coordinates] as? [[[Double]]])?[interiorIndex+1][pointIndex][longitudeIndex].rounded(.toNearestOrEven) ?? "")
                        }
                    }
                }
                
                it("deserializes and serializes in geometry") {
                    
                    let json = jsonFromFixture(Fixture.PolygonWithHolesInGeometry)
                    guard let polygon = Pytheas.shape(from: json) as? Polygon else {
                        fail("Could not deserialize polygon.")
                        return
                    }
                    
                    guard let serialized = Pytheas.geoJson(from: polygon, properties: properties(from: polygon)) else {
                        fail("Could not serialize polygon.")
                        return
                    }
                    
                    expect(polygon.title) == (json[Key.properties] as? [String:Any])?[Key.title] as? String
                    expect(polygon.subtitle) == (json[Key.properties] as? [String:Any])?[Key.subtitle] as? String
                    
                    expect(polygon.points.count) == ((json[Key.geometry] as? [String:Any])?[Key.coordinates] as? [[[Double]]])?[outerPolygonIndex].count
                    for (pointIndex, point) in polygon.points.enumerated() {
                        expect(String(format: "%.0f", point.coordinate.latitude)) == String(format: "%.0f", ((json[Key.geometry] as? [String:Any])?[Key.coordinates] as? [[[Double]]])?[outerPolygonIndex][pointIndex][latitudeIndex].rounded(.toNearestOrEven) ?? "")
                        expect(String(format: "%.0f", point.coordinate.longitude)) == String(format: "%.0f", ((json[Key.geometry] as? [String:Any])?[Key.coordinates] as? [[[Double]]])?[outerPolygonIndex][pointIndex][longitudeIndex].rounded(.toNearestOrEven) ?? "")
                        
                        expect(String(format: "%.0f", point.coordinate.latitude)) == String(format: "%.0f", ((serialized[Key.geometry] as? [String:Any])?[Key.coordinates] as? [[[Double]]])?[outerPolygonIndex][pointIndex][latitudeIndex].rounded(.toNearestOrEven) ?? "")
                        expect(String(format: "%.0f", point.coordinate.longitude)) == String(format: "%.0f", ((serialized[Key.geometry] as? [String:Any])?[Key.coordinates] as? [[[Double]]])?[outerPolygonIndex][pointIndex][longitudeIndex].rounded(.toNearestOrEven) ?? "")
                    }
                    
                    expect(polygon.interiorPolygons.count+1) == ((json[Key.geometry] as? [String:Any])?[Key.coordinates] as? [[[Double]]])?.count
                    for (interiorIndex, interior) in polygon.interiorPolygons.enumerated() {
                        expect(interior.points.count) == ((json[Key.geometry] as? [String:Any])?[Key.coordinates] as? [[[Double]]])?[interiorIndex].count
                        for (pointIndex, point) in interior.points.enumerated() {
                            expect(String(format: "%.0f", point.coordinate.latitude)) == String(format: "%.0f", ((json[Key.geometry] as? [String:Any])?[Key.coordinates] as? [[[Double]]])?[interiorIndex+1][pointIndex][latitudeIndex].rounded(.toNearestOrEven) ?? "")
                            expect(String(format: "%.0f", point.coordinate.longitude)) == String(format: "%.0f", ((json[Key.geometry] as? [String:Any])?[Key.coordinates] as? [[[Double]]])?[interiorIndex+1][pointIndex][longitudeIndex].rounded(.toNearestOrEven) ?? "")
                            
                            expect(String(format: "%.0f", point.coordinate.latitude)) == String(format: "%.0f", ((json[Key.geometry] as? [String:Any])?[Key.coordinates] as? [[[Double]]])?[interiorIndex+1][pointIndex][latitudeIndex].rounded(.toNearestOrEven) ?? "")
                            expect(String(format: "%.0f", point.coordinate.longitude)) == String(format: "%.0f", ((json[Key.geometry] as? [String:Any])?[Key.coordinates] as? [[[Double]]])?[interiorIndex+1][pointIndex][longitudeIndex].rounded(.toNearestOrEven) ?? "")
                        }
                    }
                }
            }
            
            context("deserializes multi point") {
                
                it("deserializes directly") {
                    
                    let json = jsonFromFixture(Fixture.MultiPoint)
                    guard let points = Pytheas.shape(from: json) as? [Point] else {
                        fail("Could not deserialize MultiPoint.")
                        return
                    }
                    
                    expect(points.count) == (json[Key.coordinates] as? [[Double]])?.count
                    for (pointIndex, point) in points.enumerated() {
                        expect(String(format: "%.0f", point.coordinate.latitude)) == String(format: "%.0f", (json[Key.coordinates] as? [[Double]])?[pointIndex][latitudeIndex].rounded(.toNearestOrEven) ?? "")
                        expect(String(format: "%.0f", point.coordinate.longitude)) == String(format: "%.0f", (json[Key.coordinates] as? [[Double]])?[pointIndex][longitudeIndex].rounded(.toNearestOrEven) ?? "")
                    }
                }
                
                it("deserializes and serializes in geometry") {
                    
                    let json = jsonFromFixture(Fixture.MultiPointInGeometry)
                    guard let points = Pytheas.shape(from: json) as? [Point] else {
                        fail("Could not deserialize MultiPoint.")
                        return
                    }
                    
                    expect(points.count) == ((json[Key.geometry] as? [String:Any])?[Key.coordinates] as? [[Double]])?.count
                    for (pointIndex, point) in points.enumerated() {
                        
                        expect(point.title) == (json[Key.properties] as? [String:Any])?[Key.title] as? String
                        expect(point.subtitle) == (json[Key.properties] as? [String:Any])?[Key.subtitle] as? String
                        
                        expect(String(format: "%.0f", point.coordinate.latitude)) == String(format: "%.0f", ((json[Key.geometry] as? [String:Any])?[Key.coordinates] as? [[Double]])?[pointIndex][latitudeIndex].rounded(.toNearestOrEven) ?? "")
                        expect(String(format: "%.0f", point.coordinate.longitude)) == String(format: "%.0f", ((json[Key.geometry] as? [String:Any])?[Key.coordinates] as? [[Double]])?[pointIndex][longitudeIndex].rounded(.toNearestOrEven) ?? "")
                    }
                }
            }
            
            context("deserializes multi line string") {

                it("deserializes directly") {

                    let json = jsonFromFixture("MultiLineString")
                    guard let lines = Pytheas.shape(from: json) as? [Line] else {
                        fail("Could not deserialize MultiLineString.")
                        return
                    }

                    expect(lines.count) == (json[Key.coordinates] as? [[[Double]]])?.count
                    for (lineIndex, line) in lines.enumerated() {
                        expect(line.points.count) == (json[Key.coordinates] as? [[[Double]]])?[lineIndex].count
                        for (pointIndex, point) in line.points.enumerated() {
                            expect(String(format: "%.0f", point.coordinate.latitude)) == String(format: "%.0f", (json[Key.coordinates] as? [[[Double]]])?[lineIndex][pointIndex][latitudeIndex].rounded(.toNearestOrEven) ?? "")
                            expect(String(format: "%.0f", point.coordinate.longitude)) == String(format: "%.0f", (json[Key.coordinates] as? [[[Double]]])?[lineIndex][pointIndex][longitudeIndex].rounded(.toNearestOrEven) ?? "")
                        }
                    }
                }

                it("deserializes and serializes in geometry") {

                    let json = jsonFromFixture(Fixture.MultiLineStringInGeometry)
                    guard let lines = Pytheas.shape(from: json) as? [Line] else {
                        fail("Could not deserialize MultiLineString.")
                        return
                    }

                    expect(lines.count) == ((json[Key.geometry] as? [String:Any])?[Key.coordinates] as? [[[Double]]])?.count
                    for (lineIndex, line) in lines.enumerated() {
                        expect(line.points.count) == ((json[Key.geometry] as? [String:Any])?[Key.coordinates] as? [[[Double]]])?[lineIndex].count
                        for (pointIndex, point) in line.points.enumerated() {
                            expect(String(format: "%.0f", point.coordinate.latitude)) == String(format: "%.0f", ((json[Key.geometry] as? [String:Any])?[Key.coordinates] as? [[[Double]]])?[lineIndex][pointIndex][latitudeIndex].rounded(.toNearestOrEven) ?? "")
                            expect(String(format: "%.0f", point.coordinate.longitude)) == String(format: "%.0f", ((json[Key.geometry] as? [String:Any])?[Key.coordinates] as? [[[Double]]])?[lineIndex][pointIndex][longitudeIndex].rounded(.toNearestOrEven) ?? "")
                        }
                    }
                }
            }

            context("deserializes multi polygon") {

                it("deserializes directly") {

                    let json = jsonFromFixture(Fixture.MultiPolygon)
                    guard let polygons = Pytheas.shape(from: json) as? [Polygon] else {
                        fail("Could not deserialize MultiLineString.")
                        return
                    }

                    expect(polygons.count) == (json[Key.coordinates] as? [[[[Double]]]])?.count
                    for (polygonIndex, polygon) in polygons.enumerated() {
                        expect(polygon.points.count) == (json[Key.coordinates] as? [[[[Double]]]])?[polygonIndex][outerPolygonIndex].count
                        for (pointIndex, point) in polygon.points.enumerated() {
                            expect(String(format: "%.0f", point.coordinate.latitude)) == String(format: "%.0f", (json[Key.coordinates] as? [[[[Double]]]])?[polygonIndex][outerPolygonIndex][pointIndex][latitudeIndex].rounded(.toNearestOrEven) ?? "")
                            expect(String(format: "%.0f", point.coordinate.longitude)) == String(format: "%.0f", (json[Key.coordinates] as? [[[[Double]]]])?[polygonIndex][outerPolygonIndex][pointIndex][longitudeIndex].rounded(.toNearestOrEven) ?? "")
                        }

                        expect(polygon.interiorPolygons.count+1) == (json[Key.coordinates] as? [[[[Double]]]])?[polygonIndex].count
                        for (interiorIndex, interior) in polygon.interiorPolygons.enumerated() {
                            expect(interior.points.count) == (json[Key.coordinates] as? [[[[Double]]]])?[polygonIndex][interiorIndex+1].count
                            for (pointIndex, point) in interior.points.enumerated() {
                                expect(String(format: "%.0f", point.coordinate.latitude)) == String(format: "%.0f", (json[Key.coordinates] as? [[[[Double]]]])?[polygonIndex][interiorIndex+1][pointIndex][latitudeIndex].rounded(.toNearestOrEven) ?? "")
                                expect(String(format: "%.0f", point.coordinate.longitude)) == String(format: "%.0f", (json[Key.coordinates] as? [[[[Double]]]])?[polygonIndex][interiorIndex+1][pointIndex][longitudeIndex].rounded(.toNearestOrEven) ?? "")
                            }
                        }
                    }
                }

                it("deserializes and serializes in geometry") {

                    let json = jsonFromFixture(Fixture.MultiPolygonInGeometry)
                    guard let polygons = Pytheas.shape(from: json) as? [Polygon] else {
                        fail("Could not deserialize MultiLineString.")
                        return
                    }

                    expect(polygons.count) == ((json[Key.geometry] as? [String:Any])?[Key.coordinates] as? [[[[Double]]]])?.count
                    for (polygonIndex, polygon) in polygons.enumerated() {
                        expect(polygon.points.count) == ((json[Key.geometry] as? [String:Any])?[Key.coordinates] as? [[[[Double]]]])?[polygonIndex][outerPolygonIndex].count
                        for (pointIndex, point) in polygon.points.enumerated() {
                            expect(String(format: "%.0f", point.coordinate.latitude)) == String(format: "%.0f", ((json[Key.geometry] as? [String:Any])?[Key.coordinates] as? [[[[Double]]]])?[polygonIndex][outerPolygonIndex][pointIndex][latitudeIndex].rounded(.toNearestOrEven) ?? "")
                            expect(String(format: "%.0f", point.coordinate.longitude)) == String(format: "%.0f", ((json[Key.geometry] as? [String:Any])?[Key.coordinates] as? [[[[Double]]]])?[polygonIndex][outerPolygonIndex][pointIndex][longitudeIndex].rounded(.toNearestOrEven) ?? "")
                        }

                        expect(polygon.interiorPolygons.count+1) == ((json[Key.geometry] as? [String:Any])?[Key.coordinates] as? [[[[Double]]]])?[polygonIndex].count
                        for (interiorIndex, interior) in polygon.interiorPolygons.enumerated() {
                            expect(interior.points.count) == ((json[Key.geometry] as? [String:Any])?[Key.coordinates] as? [[[[Double]]]])?[polygonIndex][interiorIndex+1].count
                            for (pointIndex, point) in interior.points.enumerated() {
                                expect(String(format: "%.0f", point.coordinate.latitude)) == String(format: "%.0f", ((json[Key.geometry] as? [String:Any])?[Key.coordinates] as? [[[[Double]]]])?[polygonIndex][interiorIndex+1][pointIndex][latitudeIndex].rounded(.toNearestOrEven) ?? "")
                                expect(String(format: "%.0f", point.coordinate.longitude)) == String(format: "%.0f", ((json[Key.geometry] as? [String:Any])?[Key.coordinates] as? [[[[Double]]]])?[polygonIndex][interiorIndex+1][pointIndex][longitudeIndex].rounded(.toNearestOrEven) ?? "")
                            }
                        }
                    }
                }
            }

            context("feature collection") {
                
                it("is deserializes and serializes") {

                    let json = jsonFromFixture(Fixture.FeatureCollection)
                    guard let features = Pytheas.shapes(from: json) as? [Shape] else {
                        fail("Could not deserialize feature collection.")
                        return
                    }
                    
                    guard let serialized = Pytheas.geoJson(from: features, properties: features.map { properties(from: $0) }) else {
                        fail("Could not serialize feature collection.")
                        return
                    }
                    
                    let first = features.first as? Point
                    expect(first?.title) == ((json[Key.features] as? [[String:Any]])?[0][Key.properties] as? [String:Any])?[Key.title] as? String
                    expect(first?.subtitle) == ((json[Key.features] as? [[String:Any]])?[0][Key.properties] as? [String:Any])?[Key.subtitle] as? String
                    expect(first?.coordinate.latitude) == (((json[Key.features] as? [[String:Any]])?[0][Key.geometry] as? [String:Any])?[Key.coordinates] as? [Double])?[latitudeIndex]
                    expect(first?.coordinate.longitude) == (((json[Key.features] as? [[String:Any]])?[0][Key.geometry] as? [String:Any])?[Key.coordinates] as? [Double])?[longitudeIndex]
                    
                    expect(first?.title) == ((serialized[Key.features] as? [[String:Any]])?[0][Key.properties] as? [String:Any])?[Key.title] as? String
                    expect(first?.subtitle) == ((serialized[Key.features] as? [[String:Any]])?[0][Key.properties] as? [String:Any])?[Key.subtitle] as? String
                    expect(first?.coordinate.latitude) == (((serialized[Key.features] as? [[String:Any]])?[0][Key.geometry] as? [String:Any])?[Key.coordinates] as? [Double])?[latitudeIndex]
                    expect(first?.coordinate.longitude) == (((serialized[Key.features] as? [[String:Any]])?[0][Key.geometry] as? [String:Any])?[Key.coordinates] as? [Double])?[longitudeIndex]
                    
                    let second = features[1] as? Point
                    expect(second?.title) == ((json[Key.features] as? [[String:Any]])?[1][Key.properties] as? [String:Any])?[Key.title] as? String
                    expect(second?.subtitle) == ((json[Key.features] as? [[String:Any]])?[1][Key.properties] as? [String:Any])?[Key.subtitle] as? String
                    expect(second?.coordinate.latitude) == (((json[Key.features] as? [[String:Any]])?[1][Key.geometry] as? [String:Any])?[Key.coordinates] as? [[Double]])?[0][latitudeIndex]
                    expect(second?.coordinate.longitude) == (((json[Key.features] as? [[String:Any]])?[1][Key.geometry] as? [String:Any])?[Key.coordinates] as? [[Double]])?[0][longitudeIndex]
                    
                    let third = features[2] as? Point
                    expect(third?.coordinate.latitude) == (((json[Key.features] as? [[String:Any]])?[1][Key.geometry] as? [String:Any])?[Key.coordinates] as? [[Double]])?[1][latitudeIndex]
                    expect(third?.coordinate.longitude) == (((json[Key.features] as? [[String:Any]])?[1][Key.geometry] as? [String:Any])?[Key.coordinates] as? [[Double]])?[1][longitudeIndex]
                }
            }
        }
    }
}
