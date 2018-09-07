//
//  TimeLineTableViewCell.swift
//  BooksApp
//
//  Created by 市村健太 on 2018/06/01.
//  Copyright © 2018年 GeekSalon. All rights reserved.
//

import UIKit

//プロトコルで共通化しておく。
protocol TimeLineTableViewCellDelegate{
    func didTapLikeButton(tableViewCell:UITableViewCell,button:UIButton)
    func didTapMenuButton(tableViewCell:UITableViewCell,button:UIButton)
    func didTapCommentsButton(tableViewCell:UITableViewCell,button:UIButton)
}

class TimeLineTableViewCell: UITableViewCell {

    @IBOutlet var userImageView:UIImageView!
    
    @IBOutlet var userNameLabel:UILabel!
    
    @IBOutlet var bookImageView:UIImageView!
    
    @IBOutlet var bookTitleLabel:UILabel!
    
    @IBOutlet var authorLabel:UILabel!
    
    @IBOutlet var likeButton:UIButton!
    
    @IBOutlet var likeCountLabel:UILabel!
    
    @IBOutlet var commentTextView:UITextView!
    
    @IBOutlet var timestampLabel:UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userImageView.layer.cornerRadius = userIMageView.bounds.width / 2.0
        userImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func like(button:UIButton){
        self.delegate?.didTapLikeButton(tabelViewCell:self,button:button)
    }
    
    @IBAction func openMenu(button:UIButton){
        self.delegate?.didTapMenuButton(tableViewCell:self,button:button)
    }
    
    @IBAction func showComments(button:UIButton){
        self.delegate?.didiTapCommentsButton(tableViewCell:self,button:button)
    }
    
    
    
    
    
    
    
    
    
}
