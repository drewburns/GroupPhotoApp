//
//  Photo.swift
//  GroupPhoto
//
//  Created by Andrew Burns on 11/25/17.
//  Copyright © 2017 Andrew Burns. All rights reserved.
//

import UIKit

class Photo: NSObject {
    var id: String?
    var path: String?
    var uploadUser: AppUser?
    var timestamp: NSNumber?
    var groups:[Group]?
}
