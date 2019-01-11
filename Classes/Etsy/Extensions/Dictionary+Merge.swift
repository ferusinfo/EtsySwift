//
//  Dictionary+Merge.swift
//  EtsyIntegration
//
//  Created by Maciej Kołek on 1/11/19.
//  Copyright © 2019 GetResponse. All rights reserved.
//

import Foundation

public extension Dictionary {
    mutating func merge(other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}
