//
//  Idea.swift
//  The Idea Pool
//
//  Created by Jason Bobier on 6/5/18.
//  Copyright © 2018 Jason Bobier. All rights reserved.
//

import Foundation

struct Idea: Codable {
	var id: String = ""
	var content: String
	var impact: Int
	var ease: Int
	var confidence: Int
	var averageScore: Double {
		get {
			return Double(self.impact + self.ease + self.confidence) / 3.0
		}
	}
	
	enum EncodingKeys: String, CodingKey {
		case content
		case impact
		case ease
		case confidence
	}
	
	enum DecodingKeys: String, CodingKey {
		case id
		case content
		case impact
		case ease
		case confidence
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: DecodingKeys.self)
		
		self.id = try container.decode(String.self, forKey: .id)
		self.content = try container.decode(String.self, forKey: .content)
		self.impact = try container.decode(Int.self, forKey: .impact)
		self.ease = try container.decode(Int.self, forKey: .ease)
		self.confidence = try container.decode(Int.self, forKey: .confidence)
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: EncodingKeys.self)
		
		try container.encode(self.content, forKey: .content)
		try container.encode(self.impact, forKey: .impact)
		try container.encode(self.ease, forKey: .ease)
		try container.encode(self.confidence, forKey: .confidence)
	}
}
