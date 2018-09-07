//
//  TimeLineViewController.swift
//  BooksApp
//
//  Created by 市村健太 on 2018/05/13.
//  Copyright © 2018年 GeekSalon. All rights reserved.
//

import UIKit
import NCMB
import Kingfisher
import SVProgressHUD
import SwiftDate
import Alamofire
import SwiftyJSON

//これはタイムラインの画面です。
class TimeLineViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    
    var selectedPost: Post?
    
    
    var posts = [Post]()
    
    //var followings = [NCMBUser]()
    
    @IBOutlet var booksTableView: UITableView!

    
    let cellIdentifier = "BooksCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(NCMBUser.current())
        
        booksTableView.dataSource = self
        
        booksTableView.dataSource = self
        //無駄な線をなくす。
        booksTableView.tableFooterView = UIView()
        //カスタムクラスをこちらに呼び込む。
        let nib = UINib(nibName: "TimeLineTableViewCell", bundle: Bundle.main)
        booksTableView.register(nib, forCellReuseIdentifier: cellIdentifier)
        //TimeLineTableViewCellを登録するという意味。
        
        // 引っ張って更新できるようにする。
        setRefreshControl()
        
        // フォロー中のユーザーを取得する。その後にフォロー中のユーザーの投稿のみ読み込み.まずフォロー中の人の更新。
        //loadFollowingUsers()
        loadTimeline()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //コメント一覧の表示画面にprepare関数を使って移動する。
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toComments" {
            let commentViewController = segue.destination as! CommentViewController
            commentViewController.postId = selectedPost?.objectId
        }
    }
    //セルの数はポストの数に一致させる。
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    //ポストに表示するデータの表示
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! TimeLineTableViewCell
        //セルのデリゲート先はこのファイルです。
        
        //セルにつけられるタグは、indexPath.rowです。
        cell.tag = indexPath.row
        
        let user = posts[indexPath.row].user
        
        cell.userNameLabel.text = user.displayName
        //下のコードは変える。自分のニフクラのファイルの、この投稿のユーザーのIDに変える。
        let userImageUrl = "https://mb.api.cloud.nifty.com/2013-09-01/applications/M8muwmQx0fj4fUqd/publicFiles/" + user.objectId
        //kfはkingfisherという意味。画像urlから画像を取ってくる。ここはユーザイメージ画像を表示させる処理。
        cell.userImageView.kf.setImage(with: URL(string: userImageUrl), placeholder: UIImage(named: "placeholder.jpg"), options: nil, progressBlock: nil, completionHandler: nil)
        
        cell.commentTextView.text = posts[indexPath.row].text
        let imageUrl = posts[indexPath.row].imageUrl
        cell.userImageView.kf.setImage(with: URL(string: imageUrl))
        
        // Likeによってハートの表示を変える
        if posts[indexPath.row].isLiked == true {
            cell.likeButton.setImage(UIImage(named: "heart-fill"), for: .normal)
        } else {
            cell.likeButton.setImage(UIImage(named: "heart-outline"), for: .normal)
        }
        
        // Likeの数
        cell.likeCountLabel.text = "\(posts[indexPath.row].likeCount)件"
        
        // タイムスタンプ(投稿日時) (※フォーマットのためにSwiftDateライブラリをimport)
        //cell.timestampLabel.text = posts[indexPath.row].createDate.string()
        
        cell.bookTitleLabel.text = posts[indexPath.row].title
        cell.authorLabel.text = posts[indexPath.row].book.author
        
        if posts[indexPath.row].book.imagePath != nil{
            cell.bookImageView.kf.setImage(with:URL(string:posts[indexPath.row].book.imagePath!), placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
        }
        
        
        return cell
    }
    //いいねボタンを押した時に、押したらいいね、もう一回押したらいいねが外れる処理。
    func didTapLikeButton(tableViewCell: UITableViewCell, button: UIButton) {
        //いいねしたユーザーに自分が含まれていない場合。
        if posts[tableViewCell.tag].isLiked == false || posts[tableViewCell.tag].isLiked == nil {
            let query = NCMBQuery(className: "Post")
            query?.getObjectInBackground(withId: posts[tableViewCell.tag].objectId, block: { (post, error) in
                post?.addUniqueObject(NCMBUser.current().objectId, forKey: "likeUser")
                post?.saveEventually({ (error) in
                    if error != nil {
                        SVProgressHUD.showError(withStatus: error!.localizedDescription)
                    } else {
                        self.loadTimeline()
                    }
                })
            })
        } else {
            //いいねしたユーザーに自分が含まれている場合。
            let query = NCMBQuery(className: "Post")
            query?.getObjectInBackground(withId: posts[tableViewCell.tag].objectId, block: { (post, error) in
                if error != nil {
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                } else {
                    post?.removeObjects(in: [NCMBUser.current().objectId], forKey: "likeUser")
                    post?.saveEventually({ (error) in
                        if error != nil {
                            SVProgressHUD.showError(withStatus: error!.localizedDescription)
                        } else {
                            self.loadTimeline()
                            //loadTimeline()は下で定義づけている。
                        }
                    })
                }
            })
        }
    }
    
    func didTapMenuButton(tableViewCell: UITableViewCell, button: UIButton) {
        //アクションをまずは定義づけて、if文でそれらを追加するかを決める。
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "削除する", style: .destructive) { (action) in
            SVProgressHUD.show()
            let query = NCMBQuery(className: "Post")
            query?.getObjectInBackground(withId: self.posts[tableViewCell.tag].objectId, block: { (post, error) in
                if error != nil {
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                } else {
                    // 取得した投稿オブジェクトを削除
                    post?.deleteInBackground({ (error) in
                        if error != nil {
                            SVProgressHUD.showError(withStatus: error!.localizedDescription)
                        } else {
                            // 再読込
                            self.loadTimeline()
                            SVProgressHUD.dismiss()
                        }
                    })
                }
            })
        }
        let reportAction = UIAlertAction(title: "報告する", style: .destructive) { (action) in
            SVProgressHUD.showSuccess(withStatus: "この投稿を報告しました。ご協力ありがとうございました。")
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        if posts[tableViewCell.tag].user.objectId == NCMBUser.current().objectId {
            // 自分の投稿なので、削除ボタンを出す
            alertController.addAction(deleteAction)
        } else {
            // 他人の投稿なので、報告ボタンを出す
            alertController.addAction(reportAction)
        }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    //コメントボタンを押したときの処理。
    func didTapCommentsButton(tableViewCell: UITableViewCell, button: UIButton) {
        // 選ばれた投稿を一時的に格納
        selectedPost = posts[tableViewCell.tag]
        
        // 遷移させる(このとき、prepareForSegue関数で値を渡す)
        self.performSegue(withIdentifier: "toComments", sender: nil)
    }
    
    func loadTimeline() {
        let query = NCMBQuery(className: "Post")
        
        // 降順.（作られて日付順に。）
        query?.order(byDescending: "createDate")
        
        // 投稿したユーザーの情報も同時取得
        query?.includeKey("user")
        
        // フォロー中の人 + 自分の投稿だけ持ってくる
        //query?.whereKey("user", containedIn: followings)
        
        // オブジェクトの取得
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            } else {
                // 投稿を格納しておく配列を初期化(これをしないとreload時にappendで二重に追加されてしまう)
                self.posts = [Post]()
                //postObjectを一個づつ取ってくる。
                for postObject in result as! [NCMBObject] {
                    // ユーザー情報をUserクラスにセット
                    let user = postObject.object(forKey: "user") as! NCMBUser
                    let booktitle = postObject.object(forKey: "booktitle") as! String
                    let author = postObject.object(forKey: "author") as! String
                    // 退会済みユーザーの投稿を避けるため、activeがfalse以外のモノだけを表示
                    if user.object(forKey: "active") as? Bool != false {
                        // 投稿したユーザーの情報をUserモデルにまとめる
                        let userModel = User(objectId: user.objectId, userName: user.userName)
                        userModel.displayName = user.object(forKey: "displayName") as? String
                        
                        let bookModel = Book(bookTitle:booktitle)
                        bookModel.author = author
                       
                        
                        // 投稿の情報を取得。NCMBの一つのクラスの横一列をobjectと呼ぶらしい。
                        let imageUrl = postObject.object(forKey: "imageUrl") as! String
                        let text = postObject.object(forKey: "text") as! String
                        
                        
                        // 2つのデータ(投稿情報と誰が投稿したか?)を合わせてPostクラスにセット
                        let post = Post(objectId: postObject.objectId, user: userModel, imageUrl: imageUrl, text: text, createDate: postObject.createDate, title: self.title!, book:bookModel)
                        
                        // likeの状況(自分が過去にLikeしているか？)によってデータを挿入
                        let likeUsers = postObject.object(forKey: "likeUser") as? [String]
                        if likeUsers?.contains(NCMBUser.current().objectId) == true {
                            post.isLiked = true
                        } else {
                            post.isLiked = false
                        }
                        
                        // いいねの件数　if let 文でnilじゃないことの担保
                        if let likes = likeUsers {
                            post.likeCount = likes.count
                        }
                        
                        /*配列に加える。最初にpostsを初期化しなかったら、reloadされるたびに、reload前に表示されていたものに、加えて二重で表示されてしまう。*/
                        
                        self.posts.append(post)
                    }
                }
                
                // 投稿のデータが揃ったらTableViewをリロード
                self.booksTableView.reloadData()
            }
        })
    }
    //ひっぱって更新できるようにする関数。
    func setRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadTimeline(refreshControl:)), for: .valueChanged)
        booksTableView.addSubview(refreshControl)
    }
    //引っ張って最新のタイムラインがリロードされる。
    @objc func reloadTimeline(refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        loadTimeline()
        // 更新が早すぎるので2秒遅延させる
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            refreshControl.endRefreshing()
        }
    }
    
//    func loadFollowingUsers() {
//        // フォロー中の人だけ持ってくる
//        let query = NCMBQuery(className: "Follow")
//        query?.includeKey("user")
//        query?.includeKey("following")
//        query?.whereKey("user", equalTo: NCMBUser.current())
//        query?.findObjectsInBackground({ (result, error) in
//            if error != nil {
//                SVProgressHUD.showError(withStatus: error!.localizedDescription)
//            } else {
//                self.followings = [NCMBUser]()
//                for following in result as! [NCMBObject] {
//                    self.followings.append(following.object(forKey: "following") as! NCMBUser)
//                }
//                self.followings.append(NCMBUser.current())
//
//                self.loadTimeline()
//            }
//        })
//    }
    



}
