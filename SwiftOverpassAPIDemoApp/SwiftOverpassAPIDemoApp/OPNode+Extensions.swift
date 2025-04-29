import Foundation
import SwiftOverpassAPI
import CoreLocation

extension OPNode: @retroactive Identifiable {
    var coordinate: CLLocationCoordinate2D {
        switch geometry {
        case .center(let coordinate):
            return coordinate
        case .polyline(let coordinates):
            return coordinates.first ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        case .polygon(let coordinates):
            return coordinates.first ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        case .multiPolygon(let polygons):
            return polygons.first?.outerRing.first ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        case .multiPolyline(let polylines):
            return polylines.first?.first ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        case .none:
            return CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
    }
} 
