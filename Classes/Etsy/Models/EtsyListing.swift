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
    private let priceString: String?
    public var price: Double? {
        if let priceString = priceString {
            return Double(priceString)
        }
        return nil
    }
    public let currencyCode: String?
    public let images: [EtsyImage]?
    public let title: String
    
    enum CodingKeys: String, CodingKey {
        case listingId = "listing_id"
        case price
        case images = "Images"
        case title
        case currencyCode = "currency_code"
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        listingId = try values.decode(Int.self, forKey: .listingId)
        images = try? values.decode([EtsyImage].self, forKey: .images)
        priceString = try values.decodeIfPresent(String.self, forKey: .price)
        currencyCode = try values.decodeIfPresent(String.self, forKey: .currencyCode)
        title = try values.decode(String.self, forKey: .title)
    }
}
