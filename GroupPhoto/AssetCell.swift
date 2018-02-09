//
//  AssetCell.swift
//  GroupPhoto
//
//  Created by Andrew Burns on 11/29/17.
//  Copyright © 2017 Andrew Burns. All rights reserved.
//

import UIKit

class AssetCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    var addButton = false
    
//    override func prepareForReuse() {
////        self.imageView.image = nil
//        super.prepareForReuse()
//    }
    
    var asset:Asset? {
        didSet {
            self.imageView.image = asset?.image
        }
    }
    
//    var asset:Asset? {
//
//        didSet {
//            if asset?.thumbnail_url == nil {
//                // image
////                imageView.image = #imageLiteral(resourceName: "placeholder")
////                self.parentViewController?.view.addSubview()
//                imageView.loadImageUsingCacheWithUrlString((asset?.image_url)!)
//                print("____________")
//                print("IMAGE URL", asset?.image_url)
//
//            } else {
//                if addButton == false {
//                    imageView.loadImageUsingCacheWithUrlString((asset?.thumbnail_url)!)
////                    imageView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
////                    let image = UIImage(named: "playbutton")
////                    let imageView2 = UIImageView(image: image!)
//////                    imageView2.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
////                    print("ADDING BUTTON")
////                    imageView2.frame = CGRect(x: 0, y: 0, width: imageView.bounds.width / 2 , height: imageView.bounds.height / 2 )
////                    //                view.addSubview(imageView)
////                    // for now because video is sideways
////
////                    self.imageView.addSubview(imageView2)
//                    addButton = true
//                }
//
//            }
//
//        }
//    }
    
    
}
