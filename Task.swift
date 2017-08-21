//
//  Task.swift
//  taskapp
//
//  Created by 西田稔 on 2017/08/17.
//  Copyright © 2017年 minoru.nishida. All rights reserved.
//

import RealmSwift

class Task: Object {
    // 管理用 ID。プライマリーキー
    dynamic var id = 0
    
    // タイトル
    dynamic var title = ""
    
    // 内容
    dynamic var contents = ""
    
    //category
    dynamic var category = ""//追加
    
    /// 日時
    dynamic var date = NSDate()
    
    /**
     id をプライマリーキーとして設定
     */
    override static func primaryKey() -> String? {
        return "id"
    }
}
