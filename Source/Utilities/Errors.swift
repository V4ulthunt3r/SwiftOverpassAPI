//
//  Errors.swift
//  SwiftOverpassAPI
//
//  Created by Peter Hildel on 4/26/25.
//  Copyright © 2025 Peter Hildel. All rights reserved.
//

import Foundation

// Errors that can result from Overpass requests
public enum OPRequestError: LocalizedError {
	case badResponse(HTTPURLResponse)
	case nilData
	case decodingFailed
	case queryCancelled
	case invalidURL
	case invalidQuery
	case queryChanged
	case operationCancelled
	
	public var errorDescription: String? {
		switch self {
		case .badResponse(let response):
			return "Bad HTTP response: \(response)"
		case .nilData:
			return "Query response returned nil data"
		case .decodingFailed:
			return "Query response data could not be decoded"
		case .queryCancelled:
			return "Query cancelled by user"
		case .invalidURL:
			return "Invalid URL for Overpass API endpoint"
		case .invalidQuery:
			return "Invalid query string"
		case .queryChanged:
			return "Query was changed before completion"
		case .operationCancelled:
			return "Decoding operation was cancelled"
		}
	}
}

// Erros that can result from decoding overpass elements
public enum OPElementDecoderError: LocalizedError {
	case invalidWayLength(wayId: Int)
	case unexpectedNil(elementId: Int)
	case emptyRelation
	
	public var errorDescription: String? {
		switch self {
		case .invalidWayLength(let id):
			return "Unable to construct the full geometry for way with id: \(id)"
		case .unexpectedNil(let elementId):
			return "Unexpected nil when decoding element with id: \(elementId)"
		case .emptyRelation:
			return "Unable to create geometry for relation with 0 valid members"
			
		}
	}
}

// Errors that can result from attempting to build invalid Overpass API queries
public enum OPQueryBuilderError: LocalizedError {
	case noElementTypesSpecified
	
	public var errorDescription: String? {
		switch self {
		case .noElementTypesSpecified:
			return "Queries must contain at least one element type"
		}
	}
}

