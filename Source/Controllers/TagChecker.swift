//
//  TagChecker.swift
//  SwiftOverpassAPI
//
//  Created by Peter Hildel on 4/26/25.
//  Copyright © 2025 Peter Hildel. All rights reserved.
//

import Foundation

// Checks whether an element contains tags that aren't included in the uninteresting tags set
struct TagChecker {
	
	static let uninterestingTags: Set<String> = [
        "source",
        "source_ref",
        "source:ref",
        "history",
        "attribution",
        "created_by",
        "tiger:county",
        "tiger:tlid",
        "tiger:upload_uuid"
	]

	static func checkForInterestingTags(amongstTags tags: [String: String]) -> Bool {
		for key in tags.keys {
			if !uninterestingTags.contains(key) {
				return true
			}
		}
		return false
	}	
}
