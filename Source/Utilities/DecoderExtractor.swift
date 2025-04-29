//
//  DecoderExtractor.swift
//  SwiftOverpassAPI
//
//  Created by Peter Hildel on 4/26/25.
//  Copyright © 2025 Peter Hildel. All rights reserved.
//

import Foundation

// A dummy class used to extract decoders that are typically only accessable in init functions. 
struct DecoderExtractor: Decodable {
	
	let decoder: Decoder
	
	init(from decoder: Decoder) throws {
		self.decoder = decoder
	}
}
