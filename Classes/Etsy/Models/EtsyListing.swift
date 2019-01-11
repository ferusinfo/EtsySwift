//
//  EtsyListing.swift
//  EtsyIntegration
//
//  Created by Maciej Kołek on 1/11/19.
//  Copyright © 2019 GetResponse. All rights reserved.
//

import Foundation

open class EtsyListing: Decodable {
    public let listingId: Int
    public let price: Double?
    public let images: [EtsyImage]
    
    enum CodingKeys: String, CodingKey {
        case listingId = "listing_id"
        case price
        case images = "Images"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        listingId = try values.decode(Int.self, forKey: .listingId)
        images = try values.decode([EtsyImage].self, forKey: .images)
        price = try? values.decode(Double.self, forKey: .price)
    }
}
