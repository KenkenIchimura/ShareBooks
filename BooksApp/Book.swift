//
//  Books.swift
//  BooksApp
//
//  Created by 市村健太 on 2018/06/01.
//  Copyright © 2018年 GeekSalon. All rights reserved.
//

import UIKit

struct Book {
    var title: String
    var imagePath: String?
    var author: String?
    
    init(title: String) {
        self.title = title
    }
}

