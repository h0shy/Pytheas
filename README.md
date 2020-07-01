# Pytheas

[![CocoaPods compatible](https://img.shields.io/cocoapods/v/Pytheas.svg)](https://cocoapods.org/pods/Pytheas)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![Swift](https://github.com/h0shy/Pytheas/workflows/Swift/badge.svg)
[![Swift Version](https://img.shields.io/badge/Swift-5.x-orange.svg)]()
[![License MIT](https://img.shields.io/npm/l/express.svg?style=flat)](https://en.wikipedia.org/wiki/MIT_License)

GeoJSON Serializer and Deserializer for MapKit and GoogleMaps.

## Features

The output model is generic, so you can instantiate MapKit and GoogleMaps points, lines, and polygons. 100% test coverage.

## Getting Started

### CocoaPods

Use the following entry in your Podfile:

```rb
pod 'Pytheas'
```

Then run `pod install`.

### Carthage

Make the following entry in your Cartfile:

```
github "h0shy/Pytheas"
```

Then run `carthage update`.

In any file you'd like to use Pytheas in, don't forget to
import the framework with `import Pytheas`.

## Usage

### GoogleMaps Point

```swift
if let point = try? Pytheas.shape(from: json) as? Point {
    let googleMapsPoint = GMSMapPoint(x: point.coordinate.latitude, y: point.coordinate.longitude)
}
```

### GoogleMaps Line

```swift
if let line = try? Pytheas.shape(from: json) as? Line {
    let path = GMSMutablePath()
    for coord in line.coordinates {
        path.add(coord)
    }
    let line = GMSPolyline(path: path)
}
```

### GoogleMaps Polygon

```swift
if let polygon = try? Pytheas.shape(from: json) as? Polygon {
    let path = GMSMutablePath()
    for coord in polygon.coordinates {
        path.add(coord)
    }
    let line = GMSPolygon(path: path)
}
```

### MapKit Point

```swift
if let point = try? Pytheas.shape(from: json) as? Point {
    let mapPoint = MKMapPoint(point.coordinate)
}
```

### MapKit Line

```swift
if let line = try? Pytheas.shape(from: json) as? Line {
    let mapLine = MKPolyline(coordinates: line.coordinates, count: line.coordinates.count)
}
```

### MapKit Polygon

```swift
if let polygon = try? Pytheas.shape(from: json) as? Polygon {
    let interiors = polygon.interiorPolygons.map { MKPolygon(coordinates: $0.coordinates, count: $0.coordinates.count) }
    let mapPolygon = MKPolygon(coordinates: polygon.coordinates, count: polygon.coordinates.count, interiorPolygons: interiors)
}
```

### FeatureCollections

```swift
let points / lines / polygons = try? Pytheas.shapes(from: json) as? [Point] / [Line] / [Polygon]
```

### Serialization

```swift
let pointJson = try? Pytheas.geoJson(from: point, properties: properties(from: point))
```

```swift
let lineJson = try? Pytheas.geoJson(from: line, properties: properties(from: line))
```

```swift
let polygonJson = try? Pytheas.geoJson(from: polygonJson, properties: properties(from: polygonJson))
```

```swift
let collectionJson = try? Pytheas.geoJson(from: features, properties: features.map {
                        var properties: [String: Any] = [:]
                        properties[Key.title] = $0.title
                        properties[Key.subtitle] = $0.subtitle
                        return properties
                     })
```

## License

Pytheas is released under an MIT license. See [License.md](https://github.com/Pytheas/Pytheas/blob/master/License.md) for more information.
