//
//  SearchViewController.swift
//  BooksApp
//
//  Created by 市村健太 on 2018/05/27.
//  Copyright © 2018年 GeekSalon. All rights reserved.
//

//ユーザーを検索する

import UIKit
import NCMB
import SVProgressHUD

class SearchViewController: UIViewController,UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,SearchTableViewCellDelegate {
    
   
    

    var users = [NCMBUser]()
    var followingUsersIds = [String]()
    var searchBar:UISearchBar!
    @IBOutlet var searchUserTableView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSearchBar()
        
        searchUserTableView.dataSource = self
        searchUserTableView.delegate = self
        
        let nib = UINib(nibName: "SearchTableViewCell", bundle: Bundle.main)
        searchUserTableView.register(nib, forCellReuseIdentifier: "Cell")
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        loadUsers(searchText:nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //let showUserViewController = segue.destination as! ShowUserViewController
        //let selectedIndex = searchUserTableView.indexPathForSelectedRow!
        //showUserViewController.selectedUser = users[selectedIndex.row]
    }
    
    func setSearchBar(){
        if let navigationBarFrame = self.navigationController?.navigationBar.bounds{
            
            let searchBar: UISearchBar = UISearchBar(frame:navigationBarFrame)
            
            searchBar.delegate = self
            searchBar.placeholder = "ユーザーを検索"
            searchBar.autocapitalizationType = UITextAutocapitalizationType.none
            navigationItem.titleView = searchBar
            navigationItem.titleView?.frame = searchBar.frame
            self.searchBar = searchBar
        }
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true,animated:true)
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SearchTableViewCell
        
        let userImageUrl = "https://mb.api.cloud.nifty.com/2013-09-01/applications/M8muwmQx0fj4fUqd/publicFiles/" + users[indexPath.row].objectId
        
        cell.userImageView.kf.setImage(with:URL(string:userImageUrl), placeholder: UIImage(named:"placeholder.jpg"), options: nil, progressBlock: nil, completionHandler: nil)
        cell.userImageView.layer.cornerRadius = cell.userImageView.bounds.width/2.0
        cell.userNameLabel.text = users[indexPath.row].object(forKey: "displayName") as? String
        
        cell.tag = indexPath.row
        cell.delegate = self
        
        if followingUsersIds.contains(users[indexPath.row].objectId) == true{
            cell.followButton.isHidden = true
        }else{
            cell.followButton.isHidden = false
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "toUser", sender: nil)
        //選択解除
        searchUserTableView.deselectRow(at: indexPath, animated: true)
    }
    
    func didTapFollowButton(tableViewCell: UITableViewCell, button: UIButton) {
        let displayName = users[tableViewCell.tag].object(forKey: "displayName") as? String
        
        let message = displayName! + "フォローしますか？"
        let alert = UIAlertController(title: "フォロー", message: message, preferredStyle: .alert)
        let okAcion = UIAlertAction(title: "フォロー", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    func follow(selectedUser:NCMBUser){
        let object = NCMBObject(className:"Follow")
        if let currentUser = NCMBUser.current(){
            object?.setObject(currentUser, forKey: "User")
            object?.setObject(selectedUser, forKey: "following")
            object?.saveInBackground({ (error) in
                if error != nil{
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                }else{
                    self.loadUsers(searchText:nil)
                }
            })
        }else{
            //currentuserがからならログイン画面に戻る
            
            let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
            UIApplication.shared.keyWindow?.rootViewController = rootViewController
            
            //ログイン状態の保持
            let ud = UserDefaults.standard
            ud.set(false, forKey:"isLogin")
            ud.synchronize()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        loadUsers(searchText:nil)
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        loadUsers(searchText:searchBar.text)
    }
    
    
    func loadUsers(searchText:String?){
        let query = NCMBUser.query()
        query?.whereKey("objectId", notEqualTo: NCMBUser.current().objectId)
        //退会済みアカウントを除外。左が参照からむ。右に条件。
        query?.whereKey("active", notEqualTo: false)
        if let text = searchText{
            print(text)
            //検索ワードがある場合
            query?.whereKey("userName", equalTo: text)
        }
        query?.limit = 50
        query?.order(byDescending:"createDate")
        query?.findObjectsInBackground({ (result, error) in
            if error != nil{
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            }else{
               //取得した新着５０件のユーザーを格納
                self.users = result as! [NCMBUser]
                self.loadFollowingUserIds()
            }
        })
        
    }
    
    func loadFollowingUserIds(){
        let query = NCMBQuery(className:"Follow")
        query?.includeKey("user")
        query?.includeKey("following")
        query?.whereKey("user",equalTo:NCMBUser.current())
        
        query?.findObjectsInBackground({ (result, error) in
            if error != nil{
                
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            }else{
                self.followingUsersIds = [String]()
                for following in result as! [NCMBObject] {
                    let user = following.object(forKey:"following") as! NCMBUser
                    self.followingUsersIds.append(user.objectId)
                }
            }
            self.searchUserTableView.reloadData()
        })
    }
    
   

}
