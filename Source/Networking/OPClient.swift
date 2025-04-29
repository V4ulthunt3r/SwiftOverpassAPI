//
//  OPClient.swift
//  SwiftOverpassAPI
//
//  Created by Peter Hildel on 4/26/25.
//  Copyright © 2025 Peter Hildel. All rights reserved.
//

import CoreLocation

// A class for making requests to an Overpass API endpoint and decoding the subsequent response
public class OPClient {
	
	/*
		These are the endpoints listed at:
		https://wiki.openstreetmap.org/wiki/Overpass_API
		
		Users can also define a custom endpoint.
	*/
	public enum Endpoint {
		case main, main2, french, swiss, kumiSystems, taiwan
		case custom(urlString: String)
		
		public var urlString: String {
			switch self {
			case .main:
				return "https://lz4.overpass-api.de/api/interpreter"
			case .main2:
				return "https://z.overpass-api.de/api/interpreter"
			case .french:
				return "http://overpass.openstreetmap.fr/api/interpreter"
			case .swiss:
				return "http://overpass.osm.ch/api/interpreter"
			case .kumiSystems:
				return "https://overpass.kumi.systems/api/interpreter"
			case .taiwan:
				return "https://overpass.nchc.org.tw"
			case .custom(let urlString):
				return urlString
			}
		}
	}
	
	private let session: URLSession
	
	// Store a reference to any url task being performed in case it needs to be cancelled.
	private var task: URLSessionDataTask?
	
	// Store the current query
	private var query: String? = nil
	
	// The selected endpoint for the overpass api post request
	public var endpoint: Endpoint
	
	// Getting and setting the url string. Has the same effect as setting the endpoint.
	public var endpointUrlString: String {
		set {
			self.endpoint = .custom(urlString: newValue)
		}
		get {
			return endpoint.urlString
		}
	}
	
	// The queue on which decoding operations are run
	private lazy var elementDecodingQueue: OperationQueue = {
	  var queue = OperationQueue()
	  queue.name = "Element decoding queue"
	  queue.maxConcurrentOperationCount = 1
	  return queue
	}()
	
	// Initializing the client with an endpoint and a url session. I've found the kumi systems endpoint to be the least restrictive in terms of usage.
	public init(
		endpoint: Endpoint = .kumiSystems,
		session: URLSession = URLSession.shared)
	{
		self.session = session
		self.endpoint = endpoint
		
	}
	
	// Initialized a client with an endpoint url string and a url session
	public init(
		endpointUrlString: String,
		session: URLSession = URLSession.shared)
	{
		self.session = session
		self.endpoint = .custom(urlString: endpointUrlString)
	}
	
	/// Fetches elements from the Overpass API using the provided query
	/// - Parameter query: The Overpass API query string. For simple queries, the OverpassQueryBuilder class can be used to conveniently build queries.
	/// - Returns: A dictionary of decoded elements keyed by their ID
	/// - Throws: OPRequestError if the request fails
	public func fetchElements(query: String) async throws -> [Int: OPElement] {
		// Store the current query and cancel any ongoing fetches
		self.query = query
		cancelFetch()
		
		// Convert the endpoint URL string into a URL
		guard let url = URL(string: endpointUrlString) else {
			throw OPRequestError.invalidURL
		}
		
		// encode the query string into data
		guard let data = query.data(using: .utf8) else {
			throw OPRequestError.invalidQuery
		}
		
		// Build the Overpass API request
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.httpBody = data
		
		// Send the request and get the response
		let (responseData, response) = try await session.data(for: request)
		
		// Check if the stored query has changed since the request was made
		guard self.query == query else {
			throw OPRequestError.queryChanged
		}
		
		// Check for HTTP errors
		if let httpResponse = response as? HTTPURLResponse,
		   httpResponse.statusCode != 200 {
			throw OPRequestError.badResponse(httpResponse)
		}
		
		// Create and run the decoding operation
		let operation = OPDecodingOperation(data: responseData)
		
		// Create a continuation to handle the operation completion
		return try await withCheckedThrowingContinuation { continuation in
			operation.completionBlock = {
				if operation.isCancelled {
					continuation.resume(throwing: OPRequestError.operationCancelled)
					return
				}
				if let error = operation.error {
					continuation.resume(throwing: error)
					return
				}
				continuation.resume(returning: operation.elements)
			}
			
			// Queue up the operation
			self.elementDecodingQueue.addOperation(operation)
		}
	}
	
	// Cancel the current fetch/decoding operation
	public func cancelFetch() {
		task?.cancel()
		elementDecodingQueue.cancelAllOperations()
	}
}
