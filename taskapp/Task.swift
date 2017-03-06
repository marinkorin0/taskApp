//
//  Task.swift
//  taskapp
//
//  Created by 小林真理子 on 2017/03/06.
//  Copyright © 2017年 小林真理子. All rights reserved.
//

import Foundation
import RealmSwift
class Task: Object {
    // 管理用 ID。プライマリーキー
    dynamic var id = 0
    
    // タイトル
    dynamic var title = ""
    
    // 内容
    dynamic var contents = ""
    
    /// 日時
    dynamic var date = NSDate()
    
    dynamic var category = ""
    
    /**
     id をプライマリーキーとして設定
     */
    override static func primaryKey() -> String? {
        return "id"
    }
}


