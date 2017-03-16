//
//  NSPredicate+Initializers.swift
//  taskapp
//
//  Created by 小林真理子 on 2017/03/15.
//  Copyright © 2017年 小林真理子. All rights reserved.
//

import Foundation
import RealmSwift

public extension NSPredicate {
    // 前後方一致検索(いわゆる、あいまい検索)
    public convenience init(_ property: String, contains q: String) {
        self.init(format: "\(property) CONTAINS '\(q)'")
    }
    
    // 前方一致検索
    public convenience init(_ property: String, beginsWith q: String) {
        self.init(format: "\(property) BEGINSWITH '\(q)'")
    }
    
    // 後方一致検索
    public convenience init(_ property: String, endsWith q: String) {
        self.init(format: "\(property) ENDSWITH '\(q)'")
    }
}
