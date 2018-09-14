//
//  friendsCell.swift
//  twitterDemo
//
//  Created by SEPL MAC on 12/09/18.
//  Copyright © 2018 nik MAC. All rights reserved.
//

import UIKit

class friendsCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
