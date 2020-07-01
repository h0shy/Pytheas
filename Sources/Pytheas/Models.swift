import Foundation
import CoreLocation

public protocol Shape {

    var title: String? { get }
    var subtitle: String? { get }
}

// Nest models inside Pytheas extension to make sure they are unique.
// Otherwise CI will fail claiming that `Polygon` is ambiguous because of an Apple typealias https://developer.apple.com/documentation/applicationservices/polygon
extension Pytheas {

    public struct Point: Shape {

        public let coordinate: CLLocationCoordinate2D
        public let title: String?
        public let subtitle: String?

        init(coordinate: CLLocationCoordinate2D, title: String? = nil, subtitle: String? = nil) {

            self.coordinate = coordinate
            self.title = title
            self.subtitle = subtitle
        }
    }

    public struct Line: Shape {

        public let coordinates: [CLLocationCoordinate2D]
        public let title: String?
        public let subtitle: String?

        public var points: [Point] { return coordinates.map { Point(coordinate: $0) } }
    }

    public struct Polygon: Shape {

        public let coordinates: [CLLocationCoordinate2D]
        public let interiorPolygons: [Polygon]
        public let title: String?
        public let subtitle: String?

        public var points: [Point] { return coordinates.map { Point(coordinate: $0) } }
    }
}

