//
//  TweetTableViewCell.swift
//  PlatziTweets
//
//  Created by Eduardo Torrez on 6/10/20.
//  Copyright © 2020 Rene Corrales. All rights reserved.
//

import UIKit
import Kingfisher

class TweetTableViewCell: UITableViewCell {
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userNickLabel: UILabel!
    @IBOutlet weak var textPostLabel: UILabel!
    @IBOutlet weak var imagePostImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var containerImage: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    public func setupCell(post: Post) {
        self.userNameLabel.text = post.author.names
        self.userNickLabel.text = post.author.nickname
        self.textPostLabel.text = post.text
        self.dateLabel.text = post.createdAt
        
        if post.hasImage {
//            configurar imagen
            self.imagePostImage.kf.setImage(with: URL(string: post.imageUrl))
        } else {
            containerImage.isHidden = true
            imagePostImage.isHidden = true
            videoButton.isHidden = true
        }
    }
    
}
