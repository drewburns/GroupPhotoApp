//
//  AddGroupMemberTableViewCell.swift
//  GroupPhoto
//
//  Created by Andrew Burns on 12/28/17.
//  Copyright © 2017 Andrew Burns. All rights reserved.
//

import UIKit
import Firebase

class AddGroupMemberTableViewCell: UITableViewCell {
    var group:Group?
    var user:AppUser? {
        didSet {
            
            print("USER", user)
            nameLabel.text! = (user?.name)!
            usernameLabel.text! = (user?.usernamesearch)!
            userImage.loadImageUsingCacheWithUrlString((user?.profileImageURL)!)
            userImage.maskCircle()
        }
    }
    
//    let base = Database.database().reference()
   
        
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    func addUserGroup() {
        let ref = Database.database().reference().child("user-groups").child((user?.id!)!)
        ref.updateChildValues([(group?.id)!:0])
    }
    
    func addGroupUser() {
        let ref = Database.database().reference().child("group-users").child((group?.id!)!)
        ref.updateChildValues([(user?.id!)!: 0])
        self.sendAddNotif(self.user!)
    }
    func sendAddNotif(_ user:AppUser) {
        if let username = UserDefaults.standard.string(forKey: "username") {
            var alert = username + " added you to " + (group?.name)!
            let token = user.token
            if token != nil && token != "none"  {
                alert = alert.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                let string = "https://wingman-notifs.herokuapp.com/send?token=" + token! + "&alert=" + alert
                
                let url = URL(string: string)
                URLSession.shared.dataTask(with: url!, completionHandler: {
                    (data, response, error) in
                    if(error != nil){
                        print("error")
                    }else{
                        do{
                            
                        } catch let error as NSError{
                            print(error)
                        }
                    }
                }).resume()
            }
        }
    }
    
    func addUserAssetRecords() {
        let ref = Database.database().reference().child("group-assets").child((group?.id)!)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let data = snapshot.value as? [String:Any] {
                for record in data {
                    let newref = Database.database().reference().child("user-assets").child((self.user?.id)!)
                    newref.updateChildValues([record.key:0])
                }
            }
        }, withCancel: nil)
    }

    @IBAction func add(_ sender: Any) {
        print("ADD BBUTTON PRESSED")
        self.addButton.isHidden = true
        addUserGroup()
        addGroupUser()
        addUserAssetRecords()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        print("test!!!!!!!!!!!")
        
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
}
