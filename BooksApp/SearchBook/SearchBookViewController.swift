//
//  SearchBookViewController.swift
//  BooksApp
//
//  Created by 市村健太 on 2018/06/01.
//  Copyright © 2018年 GeekSalon. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class SearchBookViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    
    //Bookは全て要素が初期化している。
    
    var books = [Book]()
    let cellIdentifier = "BooksInfo"
    
    @IBOutlet var searchBookTableView:UITableView!
    var searchBookSearchBar:UISearchBar!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBookTableView.tableFooterView = UIView()
        searchBookTableView.delegate = self
        searchBookTableView.dataSource = self
        
        searchBookSearchBar = UISearchBar()
        self.navigationItem.titleView = searchBookSearchBar
        searchBookSearchBar.delegate = self
        
        let nib = UINib(nibName: "SearchBookTableViewCell", bundle: Bundle.main)
        searchBookTableView.register(nib,forCellReuseIdentifier:cellIdentifier)
        
        loadBooks()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //google apiを獲得して、セル状に本の画像、著者名、タイトルを表示する。
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    //セルごとで表示される内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! SearchBookTableViewCell
        cell.bookTitleLabel.text = books[indexPath.row].bookTitle
        cell.authorLabel.text = books[indexPath.row].author
        
        //imagePathのnilチェック
        
        if books[indexPath.row].imagePath != nil{
            cell.bookImageView.kf.setImage(with: URL(string:books[indexPath.row].imagePath!), placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
        }
        return cell
    }
    //セルを押したときの反応。
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ToBookDetail", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    //セルの情報をdetailへ渡す。navigationconを挟むと値がうまく渡せない。
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToBookDetail" {
            let bookDetailViewController = segue.destination as! BookDetailViewController
            let selectedIndexPath = searchBookTableView.indexPathForSelectedRow?.row
            
            bookDetailViewController.authorText = books[selectedIndexPath!].author!
            bookDetailViewController.bookTitleText = books[selectedIndexPath!].bookTitle
            
            if books[selectedIndexPath!].imagePath != nil{
                bookDetailViewController.bookImageUrl = books[selectedIndexPath!].imagePath
            }
        }
        
    }
    
    //    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    //
    //
    //        loadBooks()
    //
    //
    //        //closeKeyboard
    //        searchBar.resignFirstResponder()
    //    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        loadBooks()
    }
    
    func loadBooks(){
        //booksを初めに初期化しないと、以前の検索結果まで表示されたままになってしまう。
        books.removeAll()
        
        if let searchTitle = searchBookSearchBar.text {
            // Input someting -> Search its title
            // E.g. Title->intitle, Author->inauthor, Publisher->inpublisher
            // https://developers.google.com/books/docs/v1/using#WorkingVolumes
            // startIndex - The position in the collection at which to start. The index of the first item is 0.
            // maxResults - The maximum number of results to return. The default is 10, and the maximum allowable value is 40.
            
            if searchTitle.count != 0 {
                //googlebooksapiに接続するURL
                let path = "https://www.googleapis.com/books/v1/volumes?q=\(searchTitle)+intitle"
                
                // include Japanese日本語でも検索できるようにする。
                let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                //pathに何かを足している。
                
                //searchされるものは、encodedpathですか？違ったらう処理を止める
                guard let searchPath = encodedPath else {
                    print("無効な検索ワードが入力されました。")
                    return
                }
                Alamofire.request(searchPath).responseJSON{(response) in
                    
                    var imagePath:String?
                    
                    let json = JSON(response.result.value!)
                    
                    json["items"].forEach({ (_,data) in
                        let title = data["volumeInfo"]["title"].string!
                        
                        
                        let authors = data["volumeInfo"]["authors"].array
                        
                        
                        if data["volumeInfo"]["imageLinks"]["thumbnail"] != nil{
                            imagePath = data["volumeInfo"]["imageLinks"]["thumbnail"].string
                        }
                        if data["publishedDate"] != nil {
                            let publishedDate = data["publishedDate"].string!
                        }
                        
                        var book = Book(bookTitle:title)
                        var authorName = ""
                        //
                        if let authors = authors{
                            for author in authors{
                                authorName = authorName + author.string!
                            }
                        }
                        book.author = authorName
                        book.imagePath = imagePath
                        self.books.append(book)
                        
                    })
                    self.searchBookTableView.reloadData()
                }
            } else {
                // Empty -> Search Random
                let path = "https://www.googleapis.com/books/v1/volumes?q=programming+intitle"
                
                Alamofire.request(path).responseJSON{(response) in
                    let json = JSON(response.result.value!)
                    print(json)
                    
                    json["items"].forEach({ (_,data) in
                        let title = data["volumeInfo"]["title"].string!
                        let authors = data["volumeInfo"]["authors"].array
                        
                        let imagePath = data["volumeInfo"]["imageLinks"]["thumbnail"].string
                        
                        if data["publishedDate"] != nil {
                            let publishedDate = data["publishedDate"].string!
                        }
                        var book = Book(bookTitle:title)
                        var authorName = ""
                        if let authors = authors {
                            for author in authors {
                                authorName = authorName + author.string!
                            }
                        }
                        book.author = authorName
                        book.imagePath = imagePath
                        self.books.append(book)
                    })
                    self.searchBookTableView.reloadData()
                }
            }
            
            
        }else{
            
            
            
        }
        
    }
    
    @IBAction func cancel(){
        self.dismiss(animated: true, completion: nil)
    }
    
}
