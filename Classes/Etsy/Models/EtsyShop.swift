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
    public var iconUrl: String?
    public var shopId: String
    
    enum CodingKeys: String, CodingKey {
        case shopName = "shop_name"
        case userId = "user_id"
        case iconUrlFullxfull = "icon_url_fullxfull"
        case shopId = "shop_id"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        shopId = try String(values.decode(Int.self, forKey: .shopId))
        name = try values.decode(String.self, forKey: .shopName)
        userId = try values.decode(Int.self, forKey: .userId)
        iconUrl = try? values.decode(String.self, forKey: .iconUrlFullxfull)
    }
}
