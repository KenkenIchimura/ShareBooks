//
//  Book.swift
//  BooksApp
//
//  Created by 市村健太 on 2018/06/03.
//  Copyright © 2018年 GeekSalon. All rights reserved.
//

import UIKit


class Book: NSObject {

    var bookTitle:String
    var author:String?
    var imagePath:String?
    
    init(bookTitle:String){
        self.bookTitle = bookTitle
    }
}
