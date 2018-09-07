//
//  Post.swift
//  BooksApp
//
//  Created by 市村健太 on 2018/05/13.
//  Copyright © 2018年 GeekSalon. All rights reserved.
//

import UIKit
//投稿の情報をまとめたもの
class Post: NSObject {
    var objectId: String
    //userクラスは、User.swiftで作った。
    var user: User
    var imageUrl: String
    var text: String
    var createDate: Date
    var isLiked: Bool?
    var comments: [Comment]?
    var likeCount: Int = 0
    var book:Book
    
    init(objectId: String, user: User, imageUrl: String, text: String, createDate: Date,title:String) {
        self.objectId = objectId
        self.user = user
        self.imageUrl = imageUrl
        self.text = text
        self.createDate = createDate
        self.title = title
    }
}
