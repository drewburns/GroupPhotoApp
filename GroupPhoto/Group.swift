//
//  Group.swift
//  GroupPhoto
//
//  Created by Andrew Burns on 11/25/17.
//  Copyright © 2017 Andrew Burns. All rights reserved.
//

import UIKit
import Firebase

class Group: NSObject {
    var id: String? 
    var name: String?
    var timestamp: NSNumber?
    var photos:[Photo]?
    var members:[AppUser]?
    var test:Int?
    var creation_date: NSNumber?
    
//    func mostRecentTimestamp() -> Int {
//        var value = 0
//        let ref = Database.database().reference().child("group-assets").child(self.id!)
//        ref.queryLimited(toLast: 1).observeSingleEvent(of: .value, with: { (snapshot) in
//            if snapshot.value != nil {
//                let newref = Database.database().reference().child("assets").child(snapshot.key)
//                newref.observeSingleEvent(of: .value, with: { (assetsnap) in
//                    if let data = assetsnap.value as? [String:Any] {
//                        self.test = data["timestamp"] as! Int
//                    }
//                }, withCancel: nil)
//            } else {
//                self.test = self.timestamp as! Int
//            }
//        }, withCancel: nil)
//        return self.test!
//    }
    
}

