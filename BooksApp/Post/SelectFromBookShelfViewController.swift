//
//  SelectFromBookShelfViewController.swift
//  BooksApp
//
//  Created by 市村健太 on 2018/06/20.
//  Copyright © 2018年 GeekSalon. All rights reserved.
//

import UIKit
import NCMB
import SVProgressHUD

class SelectFromBookShelfViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    @IBOutlet var bookCollectionView:UICollectionView!
    
    var bookCollection = [NCMBObject]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bookCollectionView.delegate = self
        bookCollectionView.dataSource = self
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //コレクションビューのセルの数。
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bookCollection.count
    }
    
    //コレクションにデータを表示させる.(画像のみ)
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let query = NCMBQuery(className: "BookCollection")
        query?.findObjectsInBackground({ (result, error) in
            if error != nil{
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            }else{
                let bookResult = result as![NCMBObject]
                self.bookCollection = bookResult
            }
        })
        
        
        let cell = bookCollectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! BookCollectionViewCell
        let bookImageUrl = bookCollection[indexPath.row].object(forKey:"bookImageUrl" )as! String
        
        cell.bookImageView.kf.setImage(with: URL(string:bookImageUrl), placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
        bookCollectionView.reloadData()
        return cell
    }
    
    //本棚の本を選択したときにそのセルにある本のデータを抽出して、クラウド上に保存し、投稿できるようにする。
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let query = NCMBQuery(className: "BookCollection")
        query?.limit = 50
        query?.findObjectsInBackground({ (result, error) in
            if error != nil{
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            }else{
                let bookResult = result as![NCMBObject]
                self.bookCollection = bookResult
            }
        })
        
        let title = bookCollection[indexPath.item].object(forKey:"title") as! String
        let author = bookCollection[indexPath.item].object(forKey:"author") as! String
        let bookImage = bookCollection[indexPath.item].object(forKey:"bookImageUrl") as! String
        //後でPostクラスを作成しておく。
        let object = NCMBObject(className: "Post")
        object?.setObject(title, forKey: "title")
        object?.setObject(author, forKey: "author")
        object?.setObject(bookImage, forKey: "bookImageUrl")
        
        object?.saveInBackground({ (error) in
            if error != nil{
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            }else{
                
            }
        })
        
        let nv = self.presentingViewController as! UINavigationController
        let vc = nv.topViewController as! PostViewController
        vc.post?.book.imagePath = bookImage
        vc.post?.book.bookTitle = title
        vc.post?.book.author = author
        
        self.dismiss(animated: true, completion: nil)
        
    }

}
