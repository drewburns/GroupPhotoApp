//
//  GroupCell.swift
//  GroupPhoto
//
//  Created by Andrew Burns on 11/25/17.
//  Copyright © 2017 Andrew Burns. All rights reserved.
//

import UIKit
import Firebase
import Cloudinary

class GroupCell: UICollectionViewCell {
    var group:Group? {
        didSet {
            groupName.text = self.group?.name
            setBackgroundImage()
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var groupName: UILabel!
    
    func setBackgroundImage(){
        let ref = Database.database().reference().child("group-assets").child(self.group!.id!)
        ref.queryLimited(toLast: 1).observeSingleEvent(of: .value, with: {(snapshot) in
            if let data = snapshot.value as? [String:Any] {
                if let first = data.first?.key {
                    let assetRef = Database.database().reference().child("assets").child(first)
                    assetRef.observeSingleEvent(of: .value, with: { (assetSnap) in
                        if let assetData = assetSnap.value as? [String:Any] {
                            self.handleAssetData(data: assetData)
                        }
                    })
                }
            }
        })
        
    }
    
    func handleAssetData(data: [String:Any]) {
        let config = CLDConfiguration(cloudName: "groupphoto", apiKey: "529763434314274", apiSecret: "euZFOHie0ArsDODOl00IwZj9gmE")
        let cloudinary = CLDCloudinary(configuration: config)
        if data["thumbnail_url"] == nil {
            // this is a image
            _ = cloudinary.createDownloader().fetchImage(data["image_url"] as! String, { (progress) in
                // progress
            }, completionHandler: { (image, error) in
                
                if error == nil {
                    DispatchQueue.main.async(execute: {
                        self.imageView.image = image
                        // dismiss unreachable view
                    })
                } else {
                    print(error)
                }
            })
        } else {
            _ = cloudinary.createDownloader().fetchImage(data["thumbnail_url"] as! String, { (progress) in
                // progress
            }, completionHandler: { (image, error) in
                print("LOADING THE IMAGE NOW!")
                if error == nil {
                    DispatchQueue.main.async(execute: {
                        self.imageView.image = image
                        // dismiss unreachable view
                    })
                } else {
                    print(error)
                }
            })

        }
    }
    
    
    
}
