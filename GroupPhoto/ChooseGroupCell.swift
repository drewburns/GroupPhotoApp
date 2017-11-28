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
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected == true {
            checkBox.setTitle("✓", for: .normal)
        } else {
            checkBox.setTitle("", for: .normal)
        }
        // Configure the view for the selected state
    }
    
    

    
    
    @IBAction func clickCheckBox(_ sender: Any) {
        if isSelected == true {
            checkBox.setTitle("", for: .normal)
            isSelected = false
        } else {
            checkBox.setTitle("✓", for: .normal)
            isSelected = true
        }
    }


}
