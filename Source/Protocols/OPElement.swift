//
//  OPElement.swift
//  SwiftOverpassAPI
//
//  Created by Peter Hildel on 4/26/25.
//  Copyright © 2025 Peter Hildel. All rights reserved.
//

import Foundation

// A protocol that defines all the properties shared by nodes, ways, and relations
public protocol OPElement {
	var id: Int { get } // The elements identifier
	var tags: [String: String] { get } // Tags that add additional details
	var isInteresting: Bool { get } // Does the element have one or more interesting tags?
	
	// If the element will be rendered as part of a parent element it does not need to be rendered individually
	var isSkippable: Bool { get set }
	
	var geometry: OPGeometry { get } // The element's geometry can take various forms.
    
    var meta: OPMeta? { get }
}
