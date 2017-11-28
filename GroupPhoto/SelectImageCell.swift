//
//  SelectImageCell.swift
//  GroupPhoto
//
//  Created by Andrew Burns on 11/25/17.
//  Copyright © 2017 Andrew Burns. All rights reserved.
//

import UIKit

class SelectImageCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var setimage:UIImage? {
        didSet {
            self.imageView.image = setimage
        }
    }
}
