//
//  NestedPolygonCoordinates.swift
//  SwiftOverpassAPI
//
//  Created by Peter Hildel on 4/26/25.
//  Copyright © 2025 Peter Hildel. All rights reserved.
//

import CoreLocation

// Used to store the coordinates for a nested polygon structure. The outer ring contains the coordinates for a single outer polygon. The inner ring contains the coordinates for any number of interior polygons. 
public struct NestedPolygonCoordinates {

	public let outerRing: [CLLocationCoordinate2D]
	public let innerRings: [[CLLocationCoordinate2D]]

    public init(
        outerRing: [CLLocationCoordinate2D],
        innerRings: [[CLLocationCoordinate2D]]
    ) {
        self.outerRing = outerRing
        self.innerRings = innerRings
    }
}
