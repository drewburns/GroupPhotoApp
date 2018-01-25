//
//  AddGroupUsersTVC.swift
//  
//
//  Created by Andrew Burns on 12/28/17.
//

import UIKit
import Firebase

class AddGroupUsersTVC: UITableViewController {
    var group:Group?
    var user:AppUser?
    var users = [AppUser]()
    var friends = [AppUser]()
    var final = [AppUser]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Add To Group"
        self.navigationItem.backBarButtonItem?.title = "Back"
        getFriends()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func getFriends() {
        var userIDs = [String]()
        self.users.map({ (user) in
            userIDs.append(user.id!)
        })
        let base = Database.database().reference()
        let ref = base.child("friendships").child((user?.id)!)
        ref.observeSingleEvent(of: .value, with:{ (snapshot) in
            if snapshot.exists() {
//                print("made it to 1")
                if let friendStrings = snapshot.value as? [String:String] {
//                    print("made it to 2")
                    for friendString in friendStrings {
                        
                        base.child("users").child(friendString.key).observeSingleEvent(of: .value, with: { (snapshot) in
                            //                            print(snapshot.value)
                            if snapshot.exists() {
//                                print("made it to 3")
                                let newUser = AppUser()
                                var params = snapshot.value as! [String:Any]
                                params["id"] = snapshot.key
                                newUser.setValuesForKeys(params)
                                if userIDs.contains(newUser.id!) {
                                    // user already exists
                                    print("USER EXISTS", newUser.name)
                                } else {
                                    print("USER ADDED", newUser.name)
                                    self.friends.append(newUser)
                                    self.friends.sort { $0.name! < $1.name! }
                                }
//                                print("FRIENDSHERE")
//                                print(self.friends)
                                self.tableView.reloadData()
//                                print(self.users.count)
                            }
                        })
                    }
                    
                }
            } else {
                print("no friends")
                // no friends
            }
        })
    }
    
    func mergeFriendsAndMembers() {
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return friends.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AddGroupMemberTableViewCell

        cell.user = self.friends[indexPath.row]
        cell.group = self.group
        // Configure the cell...

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
