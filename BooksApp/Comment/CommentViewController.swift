//
//  CommentViewController.swift
//  BooksApp
//
//  Created by 市村健太 on 2018/05/23.
//  Copyright © 2018年 GeekSalon. All rights reserved.
//

import UIKit
import NCMB
import SVProgressHUD
import Kingfisher

class CommentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    //コメントごとにIDをつける。
    var postId: String!
    
    var comments = [Comment]()
    
    @IBOutlet var commentTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableviewのデータはここで扱う。
        commentTableView.dataSource = self
        //tableviewの下の線はいらないから消す。
        commentTableView.tableFooterView = UIView()
        
        loadComments()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //セルはCellという名前の付いたもので、再生可能なものですよ。
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        //タグ付けしますよ。
        let userImageView = cell.viewWithTag(1) as! UIImageView
        let userNameLabel = cell.viewWithTag(2) as! UILabel
        let commentLabel = cell.viewWithTag(3) as! UILabel
        // let createDateLabel = cell.viewWithTag(4) as! UILabel
        
        // ユーザー画像を丸く。幅もしくは高さを２で割れば丸くなりますよ。
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        userImageView.layer.masksToBounds = true
        //上のコードでそれを実行しますよ。
        
        let user = comments[indexPath.row].user
        //ここは、自分のアプリのIDを取ってこないと何も始まらない。
        let userImagePath = "https://mb.api.cloud.nifty.com/2013-09-01/applications/自分のアプリのID/publicFiles/" + user.objectId
        userImageView.kf.setImage(with: URL(string: userImagePath))
        userNameLabel.text = user.displayName
        commentLabel.text = comments[indexPath.row].text
        
        return cell
    }
    
    func loadComments() {
        //ロードをするときに、まず始めに、表示されるコメントを初期化する。そして、追加して再表示する。
        comments = [Comment]()
        //コメントというクラスがついたものを探す。
        let query = NCMBQuery(className: "Comment")
        //postIDを探す
        query?.whereKey("postId", equalTo: postId)
        //userの情報も追加で取ってくる。
        query?.includeKey("user")
        //探したものをresult変数に入れます。
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            } else {
                //commentObjectは[NCMBObject]型にキャストします。
                for commentObject in result as! [NCMBObject] {
                    // コメントをしたユーザーの情報を取得
                    let user = commentObject.object(forKey: "user") as! NCMBUser
                    let userModel = User(objectId: user.objectId, userName: user.userName)
                    userModel.displayName = user.object(forKey: "displayName") as? String
                    
                    // コメントの文字を取得
                    let text = commentObject.object(forKey: "text") as! String
                    
                    // Commentクラスに格納
                    let comment = Comment(postId: self.postId, user: userModel, text: text, createDate: commentObject.createDate)
                    self.comments.append(comment)
                    
                    // テーブルをリロード
                    self.commentTableView.reloadData()
                }
                
            }
        })
    }
    //コメント追加する
    @IBAction func addComment() {
        let alert = UIAlertController(title: "コメント", message: "コメントを入力して下さい", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
            SVProgressHUD.show()
            let object = NCMBObject(className: "Comment")
            object?.setObject(self.postId, forKey: "postId")
            object?.setObject(NCMBUser.current(), forKey: "user")
            //ここのコードの意味がわからない
            object?.setObject(alert.textFields?.first?.text, forKey: "text")
            object?.saveInBackground({ (error) in
                if error != nil {
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                } else {
                    SVProgressHUD.dismiss()
                    self.loadComments()
                }
            })
        }
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        alert.addTextField { (textField) in
            textField.placeholder = "ここにコメントを入力"
        }
        self.present(alert, animated: true, completion: nil)
    }
}

