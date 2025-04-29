//
//  ElementCodingKeys.swift
//  SwiftOverpassAPI
//
//  Created by Peter Hildel on 4/26/25.
//  Copyright © 2025 Peter Hildel. All rights reserved.
//

import Foundation

// Coding keys that may be found w/in a single element of an overpass API result
enum ElementCodingKeys: String, CodingKey {
	case id, type, tags, center, nodes, members, geometry, version, timestamp, changeset
	case latitude = "lat"
	case longitude = "lon"
    case userId = "uid"
    case username = "user"
}
