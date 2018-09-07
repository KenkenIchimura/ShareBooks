//
//  SearchBookTableViewCell.swift
//  BooksApp
//
//  Created by 市村健太 on 2018/06/01.
//  Copyright © 2018年 GeekSalon. All rights reserved.
//

import UIKit



class SearchBookTableViewCell: UITableViewCell {
    
    @IBOutlet var bookTitleLabel:UILabel!
    @IBOutlet var bookImageView:UIImageView!
    @IBOutlet var authorLabel:UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
