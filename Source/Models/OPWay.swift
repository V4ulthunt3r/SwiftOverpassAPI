//
//  OPWay.swift
//  SwiftOverpassAPI
//
//  Created by Peter Hildel on 4/26/25.
//  Copyright © 2025 Peter Hildel. All rights reserved.
//

import MapKit

// A collection of nodes that form a polylinear or polygonal geographic feature. Common examples include road ands buildings.
public struct OPWay: OPElement{

	public let id: Int
	public let tags: [String: String]
	public let isInteresting: Bool // Way has interesting tags in it's description
	public var isSkippable: Bool // Way is already rendered by a parent relation
	public let nodes: [Int]  // Nodes for each coordinate in a way's geometry
	public let geometry: OPGeometry // For a way this will be either a polyline or a polygon
    public let meta: OPMeta?

    public init(
        id: Int,
        tags: [String : String],
        isInteresting: Bool,
        isSkippable: Bool,
        nodes: [Int],
        geometry: OPGeometry,
        meta: OPMeta?
    ) {
        self.id = id
        self.tags = tags
        self.isInteresting = isInteresting
        self.isSkippable = isSkippable
        self.nodes = nodes
        self.geometry = geometry
        self.meta = meta
    }
}
