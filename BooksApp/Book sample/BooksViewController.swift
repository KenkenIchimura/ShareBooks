//
//  BooksViewController.swift
//  BooksApp
//
//  Created by 市村健太 on 2018/06/01.
//  Copyright © 2018年 GeekSalon. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

//本を羅列するコード
class BooksViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    
    let cellIdentifier = "BooksCell"
    //Books型ということ。NSObjectでBooksについてのデータモデルをまとめる
    var books = [Book]()
    
    @IBOutlet var booksTableView: UITableView!
    @IBOutlet var booksSearchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        booksTableView.delegate = self
        booksTableView.dataSource = self
        booksSearchBar.delegate = self
        
        let nib = UINib(nibName: "BooksTableViewCell", bundle: Bundle.main)
        booksTableView.register(nib,forCellReuseIdentifier:cellIdentifier)
        
        loadBooks()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! BookTableViewCell
        cell.bookTitleLabel.text = books[indexPath.row].title
        
        if books[indexPath.row].imagePath != nil{
            cell.bookImageView.kf.setImage(with:URL(string:books[IndexPath].imagePath!), placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
        }
        return cell
    }
    // セルを押したときの動作
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    func loadBooks(searchTitle:String?){
        books = [Book]()
        
        if let searchTitle = searchTitle{
            // Input someting -> Search its title
            // E.g. Title->intitle, Author->inauthor, Publisher->inpublisher
            // https://developers.google.com/books/docs/v1/using#WorkingVolumes
            // startIndex - The position in the collection at which to start. The index of the first item is 0.
            // maxResults - The maximum number of results to return. The default is 10, and the maximum allowable value is 40.
            
            let path = "https://www.googleapis.com/books/v1/volumes?q=\(searchTitle)+intitle"
            
            // include Japanese
            let encodedPath = path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
            guard let searchPath = encodedPath else {
                print("無効な検索ワードが入力されました。")
                return
            }
            
            Alamofire.request(searchPath).responseJSON{(response)in
                let json = JSON(response.result.value!)
                //print(JSON)
                
                json["items"].forEach{(_,data) in
                    let title = data["volumeInfo"]["title"].string!
                    let authors = data["volumeInfo"]["titile"].array
                    let imagePath = data["volumeInfo"]["imageLinks"]["thumbnail"].string
                    
                    //let publishedDate = data["publishDate"].string!
                    
                    var book = Book(title:title)
                    var authorName = ""
                    if let authors = authors {
                        for author in authors{
                            authorName = authorName + author.string!
                        }
                    }
                    book.author = authorName
                    book.imagePath = imagePath
                    self.books.append(book)
                }
                self.booksTableView.reloadData()
            }
            
        }else{
            
            let path = "https://www.googleapis.com/books/v1/volumes?q=programming+intitle"
            Alamofire.request(path).responseJSON{(response) in
                let json = JSON(response.result.value!)
                
                json["item"].forEach{(_,data) in
                    let title = data["volumeInfo"]["title"].string!
                    let authors = data["volumeInfo"]["authors"].array
                    let imagePath = data["volumeInfo"]["imageLinks"]["thumbnail"].string
                    
                    var book = Book(title:title)
                    var authorName = ""
                    if let authors = authors{
                        for author in authors{
                            authorName = authorName + author.string!
                        }
                    }
                    book.author = authorName
                    book.imagePath = imagePath
                    self.books.append(book)
                }
                self.booksTableView.reloadData()
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
