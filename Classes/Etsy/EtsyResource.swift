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
    case shopListings(shopName: String, listingLimit: Int, keywords: String?, includeImages: Bool)
    
    var method: HTTPMethod {
        switch self {
        case .shops(_), .listShops(_), .shopListings(_,_,_,_):
            return .get
        }
    }
    
    var url: String {
        switch self {
        case .shops(let shopId):
            return "shops/\(shopId)"
        case .listShops(_):
            return "shops/"
        case .shopListings(let shopId, _, _, _):
            return "shops/\(shopId)/listings/active"
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .listShops(let limit):
            return ["limit": limit]
        case .shopListings(_, let limit, let keywords, let includeImages):
            var params : [String: Any] = [
                    "fields": "listing_id,price,title",
                    "limit": limit]
            if let keywords = keywords {
                params["keywords"] = keywords
            }
            if includeImages {
                params["includes"] = "Images"
            }
            
            return params
        default:
            return nil
        }
    }
}
