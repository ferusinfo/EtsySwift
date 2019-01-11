//
//  Dictionary+Decode.swift
//  EtsyIntegration
//
//  Created by Maciej Kołek on 1/10/19.
//  Copyright © 2019 GetResponse. All rights reserved.
//

import Foundation

public extension Dictionary where Key == String {
    func decode<T: Decodable>(_ type: T.Type, decodingStrategy: JSONDecoder.KeyDecodingStrategy = .convertFromSnakeCase) throws -> T {
        let json = self
        let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = decodingStrategy
        return try decoder.decode(T.self, from: jsonData)
    }
}
