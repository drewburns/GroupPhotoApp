//
//  NewChatUserTVC.swift
//  Wingman
//
//  Created by Andrew Burns on 9/2/17.
//  Copyright © 2017 Andrew Burns. All rights reserved.
//

import UIKit
import Firebase

class NewChatUserTVC: UITableViewCell {
    var user:AppUser? {
        didSet {
            nameLabel.text! = (user?.name)!
            userNameLabel.text! = (user?.usernamesearch)!
            checkbox.setTitle("", for: .normal)
            userImage.maskCircle()
        }
    }
    let base = Database.database().reference()
    
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var checkbox: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
}
