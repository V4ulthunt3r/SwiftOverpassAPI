//
//  CLLocationCoordinate2D+Extensions.swift
//  SwiftOverpassAPI
//
//  Created by Peter Hildel on 4/26/25.
//  Copyright © 2025 Peter Hildel. All rights reserved.
//

import CoreLocation

// An extension for determining whether to coordinates are equal to one another
extension CLLocationCoordinate2D {
	
	func isEqual(to coordinate: CLLocationCoordinate2D) -> Bool {
		return self.latitude == coordinate.latitude && self.longitude == coordinate.longitude
	}
}


