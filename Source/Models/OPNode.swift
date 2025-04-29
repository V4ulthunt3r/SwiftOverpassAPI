//
//  OPNode.swift
//  SwiftOverpassAPI
//
//  Created by Peter Hildel on 4/26/25.
//  Copyright © 2025 Peter Hildel. All rights reserved.
//

import MapKit

// A single geographic point. Can be a single point of interest or part of a group of nodes that form higher order objects like ways or relations.
public struct OPNode: OPElement {
	
	public let id: Int
	public let tags: [String: String]
	public let isInteresting: Bool // Node contains an interesting tag it's description
	public var isSkippable: Bool // Node is already rendered by a parent way or relation
	public let geometry: OPGeometry // For nodes this will always be a single coordinate
    public let meta: OPMeta?

    public init(
        id: Int,
        tags: [String : String],
        isInteresting: Bool,
        isSkippable: Bool,
        geometry: OPGeometry,
        meta: OPMeta?
    ) {
        self.id = id
        self.tags = tags
        self.isInteresting = isInteresting
        self.isSkippable = isSkippable
        self.geometry = geometry
        self.meta = meta
    }
}
