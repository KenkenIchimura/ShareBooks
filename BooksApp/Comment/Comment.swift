//
//  Comments.swift
//  BooksApp
//
//  Created by 市村健太 on 2018/05/23.
//  Copyright © 2018年 GeekSalon. All rights reserved.
//

import UIKit

class Comment {
    
    var postId: String
    var user: User
    var text: String
    var createDate: Date
    
    //オプショナル型以外は初期化しないとダメ。
    init(postId: String, user: User, text: String, createDate: Date) {
        self.postId = postId
        self.user = user
        self.text = text
        self.createDate = createDate
    }
}

