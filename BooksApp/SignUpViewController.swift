//
//  SignUpViewController.swift
//  BooksApp
//
//  Created by 市村健太 on 2018/05/06.
//  Copyright © 2018年 GeekSalon. All rights reserved.
//

import UIKit
import NCMB
import SVProgressHUD

class SignUpViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet var userIdTextField:UITextField!
    @IBOutlet var emailTextField:UITextField!
    @IBOutlet var passwordTextField:UITextField!
    @IBOutlet var confirmTextField:UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userIdTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmTextField.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func signUp(){
        let user = NCMBUser()
        user.userName = userIdTextField.text!
        user.mailAddress = emailTextField.text!
        
        if passwordTextField.text == confirmTextField.text{
            user.password = passwordTextField.text!
        }else{
            print("error")
        }
        user.signUpInBackground { (error) in
            if error != nil{
               SVProgressHUD.showError(withStatus: error!.localizedDescription)
            }else{
                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootTabBarController")
                UIApplication.shared.keyWindow?.rootViewController = rootViewController
            }
        }
        
    }
   
}
