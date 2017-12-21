//
//  HomeCollectionViewController.swift
//  GroupPhoto
//
//  Created by Andrew Burns on 11/23/17.
//  Copyright © 2017 Andrew Burns. All rights reserved.
//

import UIKit
import NotificationBannerSwift
import Photos
import Firebase
import AssetsPickerViewController
import Cloudinary

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}
private let reuseIdentifier = "Cell"
//    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)

class HomeCollectionViewController: UICollectionViewController {
    @IBOutlet weak var meButton: UIBarButtonItem!
//    fileprivate let itemsPerRow: CGFloat = 3
    var user:AppUser?
    var friends = [String]()
    var fromLogin = ""
    var groups:[Group] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        testCloudinary()
        onFirstLoad()
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        //Get device width
        let width = UIScreen.main.bounds.width
        
        //set section inset as per your requirement.
        layout.sectionInset = UIEdgeInsets(top: width/10, left: width/10 , bottom: 0, right: width/10 )
        
        //set cell item size here
        layout.itemSize = CGSize(width: width / 3, height: width/3)
        
        //set Minimum spacing between 2 items
        layout.minimumInteritemSpacing = width/10
        
        //set minimum vertical line spacing here between two lines in collectionview
        layout.minimumLineSpacing = width/10
        
        //apply defined layout to collectionview
        collectionView!.collectionViewLayout = layout
        getUser()
        handleGroups()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.register(GroupCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.reloadData()
        // Do any additional setup after loading the view.
    }
    
    func testCloudinary() {
    }
    
    func handleGroups(){
        observeGroups()
    }
    
    
    func observeGroups() {
        let current = Auth.auth().currentUser?.uid
        let ref = Database.database().reference().child("user-groups").child(current!)
        print("_______________")
        print("REF", ref)
        ref.observe(.childAdded, with: { (snapshot) in
            if (snapshot.value != nil) {
                self.fetchGroup(groupId: snapshot.key)
//                print("YES", snapshot.key)
            } else {
//                print("NO", snapshot.value)
            }
        })

    
    }
    
    func fetchGroup(groupId: String) {
        let groupref = Database.database().reference().child("groups").child(groupId)
        groupref.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value != nil {
                if var data = snapshot.value as? [String:Any] {
                    data["id"] = snapshot.key
                    let newGroup = Group()
                    newGroup.setValuesForKeys(data)
                    newGroup.members = []
                    self.groups.append(newGroup)

//                    self.groups.sort { $0.name! < $1.name! }
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                }
            } else {
                // error
            }
        })
    }
    
    func onFirstLoad() {
        if UserDefaults.standard.value(forKey: "first") == nil {
            print("loading wil not appear")
            let alert = UIAlertController(title: nil, message: "Loading", preferredStyle: .alert)
            
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            loadingIndicator.startAnimating();
            
            alert.view.addSubview(loadingIndicator)
            present(alert, animated: true, completion: nil)
        }
    }

    func getUser() {
        let userID = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        meButton.isEnabled = false

        //        newChatButton.isEnabled = false
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            //            print(snapshot.value)
            if snapshot.exists() == true {
                
                // get num of friends
                
                if var value = snapshot.value as? [String:Any] {
                    
                    value["id"] = snapshot.key
                    let newUser = AppUser()
                    newUser.setValuesForKeys(value)
                    self.user = newUser
                    DispatchQueue.main.async {
                        self.meButton.isEnabled = true
                        //                        self.newChatButton.isEnabled =  true
                    }
                }
                let token = UserDefaults.standard.value(forKey: "token")
                print("user token", self.user?.token)
                if  ((self.user?.token) == "none")   {
                    print("We are about to save the user's token into firebase from HomeController")
                    if Auth.auth().currentUser != nil {
                        ref.child("users").child(userID!).updateChildValues(["token": token])
                        self.user?.token = token as! String?
                        UserDefaults.standard.removeObject(forKey: "token")
                    }
                }
                //                let string = "https://wingman-notifs.herokuapp.com/send?token=" + (self.user?.token)!
                //                print("STRING", string)
                //
                //                let request = URLRequest(url: URL(string: string)!)
                //                let connection = NSURLConnection(request: request, delegate:nil, startImmediately: true)
                
                
                print(self.user?.name)
                UserDefaults.standard.set(self.user?.name, forKey: "username")
                print("STORED USER NAME",UserDefaults.standard.string(forKey: "username"))
                
                //                print(self.user?.id)
            } else{
                self.performSegue(withIdentifier: "login", sender: nil)
                
            }
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        print("DONE LOADING USER")
    }

    @IBAction func meClicked(_ sender: Any) {
        goToUser()
    }
    
    func goToUser() {
        performSegue(withIdentifier: "me", sender: user)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return groups.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! GroupCell
        print("CELL", cell)
//        cell.backgroundColor = UIColor.black
        cell.group = groups[indexPath.row]
//        print(groups[indexPath.row])
        print("_________________")
    
//        print( groups[indexPath.row])
        // Configure the cell
    
        return cell
    }

    @IBAction func uploadNew(_ sender: Any) {
        let picker = AssetsPickerViewController()
        picker.pickerDelegate = self
        present(picker, animated: true, completion: nil)
    }
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showAlbum", sender: groups[indexPath.row])
    }

    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "me" {
            
            let viewController:PopUpViewController = segue.destination as! PopUpViewController
            viewController.user = sender as? AppUser
            viewController.currentUserName = (self.user?.name)!
            
        } else if segue.identifier == "new"{
            let viewController:CreateGroupTableViewController = segue.destination as! CreateGroupTableViewController
            viewController.user = self.user
        } else if segue.identifier == "groups" {

        } else if segue.identifier == "showAlbum" {
            if let sendGroup = sender as? Group {
                let vc:AlbumCollectionVC = segue.destination as! AlbumCollectionVC
                vc.group = sendGroup
            }
        }
        
    }

}
extension HomeCollectionViewController: AssetsPickerViewControllerDelegate {
    
    func assetsPickerCannotAccessPhotoLibrary(controller: AssetsPickerViewController) {}
    func assetsPickerDidCancel(controller: AssetsPickerViewController) {}
    func assetsPicker(controller: AssetsPickerViewController, selected assets: [PHAsset]) {
//        self.performSegue(withIdentifier: "groups", sender: assets)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "pickGroups") as! ChooseGroupTVC
        vc.assets = assets
        vc.groups = self.groups
        self.navigationController?.pushViewController(vc, animated: true)
        // go to the albums table view to select which to send to
        // pass in the assets user has selected
    }
    func assetsPicker(controller: AssetsPickerViewController, shouldSelect asset: PHAsset, at indexPath: IndexPath) -> Bool {
        return true
    }
    func assetsPicker(controller: AssetsPickerViewController, didSelect asset: PHAsset, at indexPath: IndexPath) {}
    func assetsPicker(controller: AssetsPickerViewController, shouldDeselect asset: PHAsset, at indexPath: IndexPath) -> Bool {
        return true
    }
    func assetsPicker(controller: AssetsPickerViewController, didDeselect asset: PHAsset, at indexPath: IndexPath) {}
}
