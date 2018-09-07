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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
    func didTapFollowButton(tableViewCell: UITableViewCell, button: UIButton) {
        <#code#>
    }
    

    var user = [NCMBUser]()
    var followingUsersIds = [String]()
    var searchBar:UISearchBar!
    @IBOutlet var searchUserTableView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        let showUserViewController = segue.destination as! ShowUserViewController
        let selectedIndex = searchUserTableView.indexPathForSelectedRow!
        showUserViewController.selectedUser = users[selectedIndex.row]
    }
    func setSearchBar(){
        if let navigationBarFrame = self.navigationController?.navigation{
            let searchBar:UISearchBar = UISearchBar(frame:navigationBarFrame)
            searchBar.delegate = self
            searchBar.placeholder = "ユーザーを検索"
        }
        
        
    }
    func loadUsers(searchText:nil){
        let query = NCMBUser.query()
        query?.whereKey("objectId", notEqualTo: NCMBUser.current())
        query?.whereKey("active", notEqualTo: false)
        if let text = searchText{
            print(text)
            query?.whereKey("userName", notEqualTo: text)
        }
        query?.limit = 50
        query?.order(byDescending:"createDate")
        query?.findObjectsInBackground({ (result, error) in
            if error != nil{
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            }else{
                self.followingUserIds = [String]()
                
                for following in result as! [NCMBObject]()
                
                let user = following.object(value(forKey: "followings"))as! NCMBUser
                self.followingUsersIds.append(user.objectId)
                
            }
            self.searchUserTableView.reloadData()
        })
        
    }
    
    
   

}
