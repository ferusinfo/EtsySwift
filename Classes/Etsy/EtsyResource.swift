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

enum EtsyResource {
    case shops(_: String)
    
    var method: HTTPMethod {
        switch self {
        case .shops(_):
            return .get
        }
    }
    
    var url: String {
        switch self {
        case .shops(let shopId):
            return "shops/\(shopId)"
        }
    }
}
