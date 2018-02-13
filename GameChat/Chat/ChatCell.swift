//
//  ChatCell.swift
//  GameChat
//
//  Created by ido talmor on 02/01/2018.
//  Copyright © 2018 idotalmor. All rights reserved.
//

import UIKit
import FirebaseStorage
import SDWebImage


class ChatCell: UITableViewCell {

    @IBOutlet weak var chatImg: UIImageView!
    @IBOutlet weak var chatFriendName: UILabel!
    @IBOutlet weak var lastMsg: UILabel!
    @IBOutlet weak var unreadMsg: UILabel!
    
    var photoURL : String = ""{
        didSet{
    chatImg.sd_setImage(with: URL(string: photoURL), placeholderImage: UIImage(named: "placeholder.png"))
    }
}

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
