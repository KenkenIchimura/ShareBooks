//
//  EditUserInfoViewController.swift
//  BooksApp
//
//  Created by 市村健太 on 2018/05/13.
//  Copyright © 2018年 GeekSalon. All rights reserved.
//

import UIKit
import NCMB
import NYXImagesKit

class EditUserInfoViewController: UIViewController,UITextFieldDelegate,UITextViewDelegate,UINavigationControllerDelegate,
UIImagePickerControllerDelegate{
    
    @IBOutlet var userImageView:UIImageView!
    @IBOutlet var userNameTextField:UITextField!
    @IBOutlet var userIDTextField:UITextField!
    @IBOutlet var introductionTextView:UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userID = NCMBUser.current().userName
        userIDTextField.text = userID

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let file = NCMBFile.file(withName: NCMBUser.current().objectId, data: nil)as! NCMBFile
        
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
        
        if let displayName = user?.object(forKey: "displayName"){
            userNameTextField.text = displayName as! String
        }
        if let introduction = user?.object(forKey: "introduction"){
            introductionTextView.text = introduction as! String
        }
        
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
      
    }
    //ここは、閉じるボタンを別途でつけるようにする。
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    @IBAction func cancel(){
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func selectImage(){
        
        let actionController = UIAlertController(title: "画像の選択", message: "選択してください。", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "カメラ", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) == true{
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            }else{
                print("この機種でカメラは使えません")
            }
        }
        let albumAction = UIAlertAction(title: "フォトライブラリ", style:.default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == true{
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            }
        }
        actionController.addAction(cameraAction)
        actionController.addAction(albumAction)
        self.present(actionController, animated: true, completion: nil)
    }
   //画像が選ばれた時に呼ばれる関数を書く
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        userImageView.image = selectedImage
        
        let resizedImage = selectedImage.scale(byFactor: 0.2)
        picker.dismiss(animated: true, completion: nil)
        let data = UIImagePNGRepresentation(resizedImage!)
        let file = NCMBFile.file(withName: NCMBUser.current().objectId, data: data!)as! NCMBFile
        file.saveInBackground({ (error) in
            if error != nil{
                print(error)
            }else{
                self.userImageView.image = selectedImage
            }
        }) { (progress) in
            print(progress)
        }
    }
    @IBAction func saveUserInfo(){
        let user = NCMBUser.current()
        user?.setObject(userNameTextField.text!, forKey: "displayName")
        user?.setObject(introductionTextView.text!, forKey: "introduction")
        user?.setObject(userIDTextField.text, forKey: "userName")
        user?.saveInBackground({ (error) in
            if error != nil{
                print(error)
            }else{
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    //画像をNCMB上にあげるけど、最近のiphoneは高画質すぎるからリサイズして載せないといけない。
    
    
    
}
