//
//  ChooseGroupCell.swift
//  GroupPhoto
//
//  Created by Andrew Burns on 11/27/17.
//  Copyright © 2017 Andrew Burns. All rights reserved.
//

import UIKit

class ChooseGroupCell: UITableViewCell {
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var checkBox: UIButton!
    
    var group:Group? {
        didSet {
            self.groupName.text = self.group?.name
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }



}
