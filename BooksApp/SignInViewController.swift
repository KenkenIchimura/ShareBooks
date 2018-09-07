//
//  SignInViewController.swift
//  BooksApp
//
//  Created by 市村健太 on 2018/05/06.
//  Copyright © 2018年 GeekSalon. All rights reserved.
//

import UIKit
import NCMB


class SignInViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet var userIdTextField:UITextField!
    @IBOutlet var passwordTextField:UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userIdTextField.delegate = self
        passwordTextField.delegate = self
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func signIn(){
        let user = NCMBUser.current()
        
        if (userIdTextField.text?.characters.count)!>0 && (passwordTextField.text?.characters.count)!>0{
            NCMBUser.logInWithUsername(inBackground: userIdTextField.text!, password: passwordTextField.text!, block: { (user, error) in
                if error != nil{
                    print(error)
                }else{
                    let storyboard = UIStoryboard(name:"Main", bundle: Bundle.main)
                    let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootTabBarController")
                    UIApplication.shared.keyWindow?.rootViewController = rootViewController
                }
            let ud = UserDefaults.standard
                ud.set(true, forKey: "isLogin")
                ud.synchronize()
            })
        }
    }
    @IBAction func toSignUp(){
        self.performSegue(withIdentifier: "toSignUp", sender: nil)
    }

    
    

}
