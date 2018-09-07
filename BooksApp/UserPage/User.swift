//
//  User.swift
//  BooksApp
//
//  Created by 市村健太 on 2018/05/13.
//  Copyright © 2018年 GeekSalon. All rights reserved.
//

import UIKit
// ユーザーの情報をまとめる
//NSObjectで作ったものは全てで使える

class User: NSObject {
    var objectId: String
    var userName: String
    var displayName: String?
    var introduction: String?
    //displayNameとintroductionはnilになる可能性があるので、?としておく。
    //オプショナル型以外のものは、nilが許されないので、イニシャライザを使って初期化しておく。
    init(objectId: String, userName: String) {
        self.objectId = objectId
        self.userName = userName
    }
}
