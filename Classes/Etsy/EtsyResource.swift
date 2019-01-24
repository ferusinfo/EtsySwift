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
    case shopListingImages(name: String, listingLimit: Int, keywords: String?)
    
    var method: HTTPMethod {
        switch self {
        case .shops(_), .listShops(_), .shopListingImages(_,_,_):
            return .get
        }
    }
    
    var url: String {
        switch self {
        case .shops(let shopId):
            return "shops/\(shopId)"
        case .listShops(_):
            return "shops/"
        case .shopListingImages(let shopId, _, _):
            return "shops/\(shopId)/listings/active"
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .listShops(let limit):
            return ["limit": limit]
        case .shopListingImages(_, let limit, let keywords):
            var params : [String: Any] =  ["includes": "Images",
                    "fields": "listing_id,price,title",
                    "limit": limit]
            if let keywords = keywords {
                params["keywords"] = keywords
            }
            return params
        default:
            return nil
        }
    }
}
