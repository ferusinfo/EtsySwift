//
//  EtsyResponse.swift
//  EtsyIntegration
//
//  Created by Maciej Kołek on 1/10/19.
//  Copyright © 2019 GetResponse. All rights reserved.
//

import Foundation

open class EtsyResponse<T: Decodable>: Decodable {
    public var results: [T]
    
    enum CodingKeys: String, CodingKey {
        case results
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        results = try values.decode([T].self, forKey: .results)
    }
}
