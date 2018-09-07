//
//  BookDetailViewController.swift
//  BooksApp
//
//  Created by 市村健太 on 2018/06/13.
//  Copyright © 2018年 GeekSalon. All rights reserved.
//

import UIKit
import NCMB

class BookDetailViewController: UIViewController {

    @IBOutlet var bookImageView:UIImageView!
    @IBOutlet var authorLabel:UILabel!
    @IBOutlet var bookTitleLabel:UILabel!
    var bookImageUrl:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        object?.setObject(bookImageUrl!, forKey: "bookImageUrl")
        object?.saveInBackground({ (error) in
            if error != nil{
                print(error)
            }else{
                self.dismiss(animated: true, completion: nil)
            }
        })
    }

}
