//
//  EtsyPagination.swift
//  EtsyIntegration
//
//  Created by Bartosz Tułodziecki on 24/04/2019.
//  Copyright © 2019 GetResponse. All rights reserved.
//

import Foundation

open class EtsyPagination: Decodable {
    public var effectivePage: Int?
    public var nextPage: Int?
    public var effectiveOffset: Int?
    public var nextOffset: Int?
    
    public var hasPrevPage: Bool {
        if let currentPage = effectivePage, currentPage > 1 {
            return true
        }
        return false
    }
    
    public var hasNextPage: Bool {
        return nextPage != nil
    }
    
    enum CodingKeys: String, CodingKey {
        case effectivePage = "effective_page"
        case nextPage = "next_page"
        case effectiveOffset = "effective_offset"
        case nextOffset = "next_offset"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        effectivePage = try values.decodeIfPresent(Int.self, forKey: .effectivePage)
        nextPage = try values.decodeIfPresent(Int.self, forKey: .nextPage)
        effectiveOffset = try values.decodeIfPresent(Int.self, forKey: .effectiveOffset)
        nextOffset = try values.decodeIfPresent(Int.self, forKey: .nextOffset)
    }
}
