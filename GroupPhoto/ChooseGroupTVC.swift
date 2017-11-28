//
//  ChooseGroupTVC.swift
//  GroupPhoto
//
//  Created by Andrew Burns on 11/27/17.
//  Copyright © 2017 Andrew Burns. All rights reserved.
//

import UIKit
import Photos
import Firebase
import AVKit

class ChooseGroupTVC: UITableViewController {
    
    var assets:[PHAsset]?
    var groups:[Group] = []
    
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserGroups()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func loadUserGroups() {
        if let current = Auth.auth().currentUser?.uid {
            let ref = Database.database().reference().child("user-groups").child(current)
            ref.observe(.childAdded, with: { (snapshot) in
                if snapshot.exists() {
                    self.getGroupFromKey(key: snapshot.key)
                }
            })
            
            
        }
    }
    
    func getGroupFromKey(key: String) {
        let newref = Database.database().reference().child("groups").child(key)
        newref.observeSingleEvent(of: .value, with: {(snapshot) in
            if snapshot.exists() {
                if var data = snapshot.value as? [String:Any] {
                    data["id"] = snapshot.key
                    let group = Group()
                    group.setValuesForKeys(data)
                    self.groups.append(group)
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    })

                }
            }
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return groups.count
    }
    
    
    @IBAction func finished(_ sender: Any) {
        for asset in self.assets! {
            if (asset.mediaType == PHAssetMediaType.video) {
                PHCachingImageManager().requestAVAsset(forVideo: asset, options: nil) { (asset, audioMix, args) in
                    let video = asset
                    let urlThing = video as? AVURLAsset
                     let storageRef = Storage.storage().reference().child("video.mp4")
                    storageRef.putFile(from: (urlThing?.url)!)
                    // ready to upload this url
                }

            } else if (asset.mediaType == PHAssetMediaType.image) {
                let image = getUIImage(asset: asset)
                print(image)
                let storageRef = Storage.storage().reference().child("image.png") // name this better probably in the group file
                if let uploadData = UIImagePNGRepresentation(image!) {
                    storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                        
                        if error != nil {
                            print("Failed to upload image:", error!)
                            return
                        }
                        
                        // now we must do stuff with this ref and store it in other places
                        
                        
                    })
                }
            
            } else {
                print("WTF IS HAPPENING")
                // wat did they upload???
            }
            
        }
    }
    
    
    func getUIImage(asset: PHAsset) -> UIImage? {
        
        var img: UIImage?
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .original
    
        options.isSynchronous = true
        manager.requestImageData(for: asset, options: options) { data, _, _, _ in
            
            if let data = data {
                img = UIImage(data: data)
            }
        }
        return img
    }



    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChooseGroupCell
        
        cell.group = groups[indexPath.row]

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
