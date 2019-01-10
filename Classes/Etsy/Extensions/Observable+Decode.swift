//
//  Observable+Decode.swift
//  EtsyIntegration
//
//  Created by Maciej Kołek on 1/10/19.
//  Copyright © 2019 GetResponse. All rights reserved.
//

import Foundation
import RxSwift

extension Observable where E == Dictionary<String, Any> {
    func decodedAs<R: Decodable>(_ type: R.Type) -> Observable<R> {
        return map { data -> R in
            return try data.decode(R.self)
        }
    }
}
