//
//  BookDetailViewController.swift
//  BooksApp
//
//  Created by 市村健太 on 2018/06/13.
//  Copyright © 2018年 GeekSalon. All rights reserved.
//

import UIKit
import NCMB
import Kingfisher

class BookDetailViewController: UIViewController {

    //""はnilではない。文字列はあると認識される。
    
    @IBOutlet var bookImageView:UIImageView!
    @IBOutlet var authorLabel:UILabel!
    var authorText = ""
    @IBOutlet var bookTitleLabel:UILabel!
    var bookImageUrl:String?
    var bookTitleText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authorLabel.text = authorText
        bookTitleLabel.text = bookTitleText
        
        if bookImageUrl != nil{
            bookImageView.kf.setImage(with: URL(string:bookImageUrl!), placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
        }
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registerBook(){
        let object = NCMBObject(className: "BookCollection")
        object?.setObject(bookTitleLabel.text!, forKey: "title")
        object?.setObject(authorLabel.text!, forKey: "author")
        if bookImageUrl != nil{
            object?.setObject(bookImageUrl!, forKey: "bookImageUrl")
        }
        object?.saveInBackground({ (error) in
            if error != nil{
                print(error)
            }else{
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    @IBAction func cancel(){
        self.dismiss(animated: true, completion: nil)
        
    }

}
