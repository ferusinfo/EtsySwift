//
//  EtsyShop.swift
//  EtsyIntegration
//
//  Created by Maciej Kołek on 1/10/19.
//  Copyright © 2019 GetResponse. All rights reserved.
//

import Foundation

open class EtsyShop: Decodable {
    public var name: String
    public var userId: Int
    
    enum CodingKeys: String, CodingKey {
        case shopName
        case userId
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try values.decode(String.self, forKey: .shopName)
        userId = try values.decode(Int.self, forKey: .userId)
    }
}
