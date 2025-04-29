//
//  OPMapKitVisualization.swift
//  SwiftOverpassAPI
//
//  Created by Peter Hildel on 4/26/25.
//  Copyright © 2025 Peter Hildel. All rights reserved.
//

import MapKit

/*
	Mapkit visualization types for overpass elements. Different returned elements require different visualization types.
*/
public enum OPMapKitVisualization {
	case annotation(MKAnnotation)
	case polygon(MKPolygon)
	case polyline(MKPolyline)
	case polygons([MKPolygon])
	case polylines([MKPolyline])
}
