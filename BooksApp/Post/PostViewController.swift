//
//  PostViewController.swift
//  BooksApp
//
//  Created by 市村健太 on 2018/05/12.
//  Copyright © 2018年 GeekSalon. All rights reserved.
//

import UIKit
import NYXImagesKit
import NCMB
import UITextView_Placeholder
import SVProgressHUD
import Alamofire
import SwiftyJSON

class PostViewController:UIViewController,UINavigationControllerDelegate,UITextViewDelegate,UISearchBarDelegate {
    
    
    var post:Post?
    
    let placeHolderImage = UIImage(named:"placeholder.jpg")
    
    
    
    @IBOutlet var postTextView:UITextView!
    @IBOutlet var postButton:UIBarButtonItem!
    @IBOutlet var bookImageView:UIImageView!
    @IBOutlet var authorNameLabel:UILabel!
    @IBOutlet var bookTitleLabel:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        //最初はポストボタンは押せない。
        postButton.isEnabled = false
        postTextView.placeholder = "レビューを書く"
        postTextView.delegate = self
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        if let post?.book.imagePath = bookImagePath {
//            bookImageView.kf.setImage(with: URL(string:(bookImagePath)!), placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
//            authorNameLabel.text = post?.book.author
//        }
//        
//        
//        
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
   
    
    
//    //imagePickerControllerが作動した時の動作。
//   func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
//
//        resizedImage = selectedImage.scale(byFactor: 0.4)
//        postImageView.image = resizedImage
//        picker.dismiss(animated: true, completion: nil)
//
//
//    }
//
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
//    //画像を選択するボタン（本当はAPIでやる。
//   @IBAction func selectImage(){
//        let alertController = UIAlertController(title: "本の画像を選択", message: "シェアする画像を選択してください", preferredStyle: .actionSheet)
//        let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action) in
//            alertController.dismiss(animated: true, completion: nil)
//        }
//        let cameraAction = UIAlertAction(title: "カメラで撮影", style: .default) { (action) in
//            if UIImagePickerController.isSourceTypeAvailable(.camera) == true{
//                let picker = UIImagePickerController()
//                picker.sourceType = .camera
//                picker.delegate = self
//                self.present(picker, animated: true, completion: nil)
//            }else{
//                print("この機種ではカメラは使用できません。")
//            }
//        }
//        let photoLibraryAction = UIAlertAction(title: "フォトライブラリから選択", style: .default) { (action) in
//            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == true{
//                let picker = UIImagePickerController()
//                picker.sourceType = .photoLibrary
//                picker.delegate = self
//            }else{
//                print("この機種ではフォトライブラリは使用できません。")
//            }
//        }
//        alertController.addAction(cancelAction)
//        alertController.addAction(cameraAction)
//        alertController.addAction(photoLibraryAction)
//        self.present(alertController, animated: true, completion: nil)
//    }

    
    @IBAction func postReview(){
        
        let object = NCMBObject(className: "Post")
        
        object?.setObject(post?.book.imagePath!, forKey: "imageUrl")
        object?.setObject(post?.book.author!, forKey: "author")
        object?.setObject(post?.book.bookTitle, forKey: "bookTitle")
        object?.setObject(postTextView.text!, forKey: "text")
        object?.setObject(NCMBUser.current(), forKey: "user")
        
        object?.saveInBackground({ (error) in
            if error != nil{
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            }else{
                
            }
        })
        
        
        
        
    }
    func confirmContent() {
        if postTextView.text.characters.count > 0 && bookImageView.image != placeHolderImage {
            
            postButton.isEnabled = true
        } else {
            postButton.isEnabled = false
        }
    }
    
    @IBAction func cancel() {
        if postTextView.isFirstResponder == true {
            postTextView.resignFirstResponder()
        }
        
        let alert = UIAlertController(title: "投稿内容の破棄", message: "入力中の投稿内容を破棄しますか？", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.postTextView.text = nil
            self.bookImageView.image = UIImage(named: "photo-placeholder")
            self.confirmContent()
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //本棚から本を選択してそれが表示されるようにする。
    @IBAction func moveToSelectBook(){
        self.performSegue(withIdentifier: "toSelect", sender: nil)
        
    }
    
    
}

    
    
    
    
    
    
    
    
    

