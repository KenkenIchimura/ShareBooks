//
//  SearachTableViewCell.swift
//  BooksApp
//
//  Created by 市村健太 on 2018/05/27.
//  Copyright © 2018年 GeekSalon. All rights reserved.
//

import UIKit
import NCMB

//このファイルで定義するけど、viewControllerで反映し処理したいから、プロトコル宣言をしておく。
protocol SearchTableViewCellDelegate {
    func didTapFollowButton(tableViewCell:UITableViewCell,button:UIButton)
}


class SearachTableViewCell: UITableViewCell {

    
    var delegate:SearchTableViewCellDelegate?
    @IBOutlet var userImageView:UIImageView!
    @IBOutlet var userNameLabel:UILabel!
    @IBOutlet var followButton:UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func follow(button:UIButton){
        self.delegate?.didTapFollowButton(tableViewCell:self, button: button)
    }
    
    
}
