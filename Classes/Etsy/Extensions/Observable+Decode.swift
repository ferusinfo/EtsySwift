//
//  Observable+Decode.swift
//  EtsyIntegration
//
//  Created by Maciej Kołek on 1/10/19.
//  Copyright © 2019 GetResponse. All rights reserved.
//

import Foundation
import RxSwift

public extension Observable where E == Dictionary<String, Any> {
    func decodedAs<R: Decodable>(_ type: R.Type, decodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) -> Observable<R> {
        return map { data -> R in
            return try data.decode(R.self, decodingStrategy: decodingStrategy)
        }
    }
}
