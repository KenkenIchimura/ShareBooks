//
//  UserPageViewController.swift
//  BooksApp
//
//  Created by 市村健太 on 2018/05/06.
//  Copyright © 2018年 GeekSalon. All rights reserved.
//

import UIKit
import NCMB
import Kingfisher

class UserPageViewController: UIViewController,UITextFieldDelegate,UITextViewDelegate,UINavigationControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource {
   
    
    @IBOutlet var userImageView:UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var introductionTextView:UITextView!
    @IBOutlet var postCount:UILabel!
    @IBOutlet var goodCount:UILabel!
    @IBOutlet var bookCollectionView:UICollectionView!
    
    var bookCollection = [NCMBObject]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bookCollectionView.delegate = self
        bookCollectionView.dataSource = self
        userImageView.layer.cornerRadius = userImageView.bounds.width/2.0
        userImageView.layer.masksToBounds = true
        introductionTextView.delegate = self
        
        //カスタムセルの登録
        let nib = UINib(nibName: "BookColletionViewCell", bundle: Bundle.main)
        bookCollectionView.register(nib, forCellWithReuseIdentifier: "Cell")
        
        //本棚の本をロードする
        loadBook()
    }
    override func viewWillAppear(_ animated: Bool) {
        
        if let user = NCMBUser.current(){
            let file = NCMBFile.file(withName: user.objectId, data: nil) as! NCMBFile
            
            file.getDataInBackground({ (data, error) in
                if error != nil{
                    print(error)
                }else{
                    if data != nil{
                        let image = UIImage(data: data!)
                        self.userImageView.image = image
                    }
                }
            }) { (progress) in
                print(progress)
            }
            let user = NCMBUser.current()
            userNameLabel.text = user?.object(forKey: "displayName")as? String
            introductionTextView.text = user?.object(forKey: "introduction")as? String
            self.navigationItem.title = user?.userName
            
        }else{
            //ログアウト成功（SignIn画面に戻る）
            let storyboard = UIStoryboard(name: "Sign", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "SignInVIewController")
            UIApplication.shared.keyWindow?.rootViewController = rootViewController
            //ログアウト状態を解除する ユーザデフォルツは一端末につき一つ
            
            let ud = UserDefaults.standard
            ud.set(false, forKey: "isLogin")
            ud.synchronize()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //ログアウトのコードを書く
    @IBAction func showMenu(){
        let alert = UIAlertController(title: "メニュー", message: "ログアウト", preferredStyle: .actionSheet)
        let logoutAction = UIAlertAction(title: "ログアウト", style: .default) { (action) in
            NCMBUser.logOutInBackground({ (error) in
                if error != nil{
                    print(error)
                }else{
                    //ログアウト成功（SignIn画面に戻る）
                    let storyboard = UIStoryboard(name: "Sign", bundle: Bundle.main)
                    let rootViewController = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
                    UIApplication.shared.keyWindow?.rootViewController = rootViewController
                    //ログアウト状態を解除する ユーザデフォルツは一端末につき一つ
                    
                    let ud = UserDefaults.standard
                    ud.set(false, forKey: "isLogin")
                    ud.synchronize()
                }
            })
        }
        
        //退会機能
        
        let deleteAction = UIAlertAction(title: "退会", style:.default) { (action) in
            let user = NCMBUser.current()
            user?.deleteInBackground({ (error) in
                if error != nil{
                    print(error)
                }else{
                    //デリートできるなら、ログアウト状態かつ、udのログイン状態を解除かつsignin画面に戻る
                    let ud = UserDefaults.standard
                    ud.set(false, forKey: "isLogin")
                    let storyboard = UIStoryboard(name: "Sign", bundle: Bundle.main)
                    let rootViewControleller = storyboard.instantiateViewController(withIdentifier: "SignViewController")
                    UIApplication.shared.keyWindow?.rootViewController = rootViewControleller
                    
                }
            })
        }
        let canelAction = UIAlertAction(title: "キャンセル", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(logoutAction)
        alert.addAction(canelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addBook(){
        performSegue(withIdentifier: "registerBook", sender: nil)
    }
    //コレクションのデータの数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bookCollection.count
    }
    
    //コレクションにデータを表示させる.(画像のみ)
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = bookCollectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! BookCollectionViewCell
        let bookImageUrl = bookCollection[indexPath.row].object(forKey:"bookImageUrl" )as! String
        cell.bookImageView.kf.setImage(with: URL(string:bookImageUrl), placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
        bookCollectionView.reloadData()
        return cell
    }
    
    //本棚の更新
    func loadBook(){
        let query = NCMBQuery(className: "BookCollection")
        query?.whereKey("bookImageUrl", equalTo: nil)
        query?.findObjectsInBackground({ (result, error) in
            if error != nil{
                print(error)
            }else{
                let bookImageUrl = result as![NCMBObject]
                self.bookCollection.append(bookImageUrl)
                self.bookCollectionView.reloadData()
            }
        })
        
    }
    
    //本棚の本を押したときに、遷移して色々設定できるやつ。
    
    
    
    
    
    
    
    

}
