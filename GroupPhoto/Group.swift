//
//  Group.swift
//  GroupPhoto
//
//  Created by Andrew Burns on 11/25/17.
//  Copyright © 2017 Andrew Burns. All rights reserved.
//

import UIKit

class Group: NSObject {
    var id: String?
    var name: String?
    var timestamp: NSNumber?
    var photos:[Photo]?
    var members:[AppUser]?
}

