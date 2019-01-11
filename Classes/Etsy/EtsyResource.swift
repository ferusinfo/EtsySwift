//
//  EtsyResource.swift
//  EtsyIntegration
//
//  Created by Maciej Kołek on 1/10/19.
//  Copyright © 2019 GetResponse. All rights reserved.
//

import Foundation
import Alamofire
import RxAlamofire

public enum EtsyResource {
    case listShops(limit: Int)
    case shops(_: String)
    case shopListingImages(name: String, listingLimit: Int)
    
    var method: HTTPMethod {
        switch self {
        case .shops(_), .listShops(_), .shopListingImages(_,_):
            return .get
        }
    }
    
    var url: String {
        switch self {
        case .shops(let shopId):
            return "shops/\(shopId)"
        case .listShops(_):
            return "shops/"
        case .shopListingImages(let shopId, _):
            return "shops/\(shopId)/listings/active"
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .listShops(let limit):
            return ["limit": limit]
        case .shopListingImages(_, let limit):
            return ["includes": "Images",
                    "fields": "listing_id,price",
                    "limit": limit]
        default:
            return nil
        }
    }
}
