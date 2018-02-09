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
import Crashlytics

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
    var picturesDictionary:[Group:Int] = [:]
    var refresher:UIRefreshControl!
    
    let alert = UIAlertController(title: nil, message: "Loading", preferredStyle: .alert)
    
    let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))

    func testUserLogin() {
        if Auth.auth().currentUser == nil {
            do {
                try Auth.auth().signOut()
            } catch let logerror {
                print(logerror)
            }
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "login")
            self.show(vc, sender: self)
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        testUserLogin()
        testCloudinary()
        onFirstLoad()
        loadingIndicator.stopAnimating()
        self.dismiss(animated: true, completion: nil)
//        let button = UIButton(type: .roundedRect)
//        button.frame = CGRect(x: 20, y: 50, width: 100, height: 30)
//        button.setTitle("Crash", for: [])
//        button.addTarget(self, action: #selector(self.crashButtonTapped(_:)), for: .touchUpInside)
//        view.addSubview(button)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        self.refresher = UIRefreshControl()
        self.collectionView!.alwaysBounceVertical = true
        self.refresher.tintColor = UIColor.blue
        self.refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        self.collectionView!.addSubview(refresher)
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

//        self.collectionView?.reloadData()
        self.collectionView?.reloadData()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.register(GroupCell.self, forCellWithReuseIdentifier: reuseIdentifier)
//        collectionView?.reloadData()
        // Do any additional setup after loading the view.
    }
    
    func testCloudinary() {
    }
    
    @IBAction func crashButtonTapped(_ sender: AnyObject) {
        let x: Int? = nil
        let y = 5 + x!
    }
    
    func loadData() {
        //code to execute during refresher
        orderGroups()
        self.collectionView?.reloadData()
        stopRefresher()         //Call this to stop refresher
    }
    
    func stopRefresher() {
        self.refresher.endRefreshing()
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
//                    print("TIMESTAMOSDKSD", newGroup.mostRecentTimestamp())
                    self.groups.append(newGroup)
                    self.orderGroups()
                    DispatchQueue.main.async {
                        self.orderGroups()
                        self.collectionView?.reloadData()
//                        collectionView?.reloadItems(at: [])
                    }
                }
            } else {
                // error
            }
        })
    }
    

    
    // DO THIS
    func orderGroups() {
        self.groups = self.groups.sorted(by: { Int($0.timestamp) > Int($1.timestamp) })
    }
    
//    func sortDictionary(_:[Any:Int]) -> [Any] {
//
//    }
    
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
//                if  ((self.user?.token) == "none")   {
                    print("We are about to save the user's token into firebase from HomeController")
                    if Auth.auth().currentUser != nil {
                        ref.child("users").child(userID!).updateChildValues(["token": token])
                        self.user?.token = token as! String?
                        UserDefaults.standard.removeObject(forKey: "token")
                    }
//                }
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
                self.testUserLogin()
//                self.performSegue(withIdentifier: "login", sender: nil)
                
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
    func observeGroupChanges() {
        for group in self.groups {
            print("GROUP", group.name)
        }
    }

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
        cell.imageView.image = #imageLiteral(resourceName: "placeholder")
        // setImageForCell(indexPath: indexPath, group: groups[indexPath.row])
        print("TEST TEST TEST")
//        cell.timestamp = 1000
        getAssetInfo(group: cell.group!, indexPath: indexPath)
//        print( groups[indexPath.row])
        // Configure the cell
    
        return cell
    }
    func getAssetInfo(group: Group, indexPath: IndexPath) {
        var returnData:[String:Any]?
        let ref = Database.database().reference().child("group-assets").child(group.id!)
        ref.queryLimited(toLast: 1).observeSingleEvent(of: .value, with: {(snapshot) in
            if var data = snapshot.value as? [String:Any] {
                if let first = data.first?.key {
                    let assetRef = Database.database().reference().child("assets").child(first)
                    assetRef.observeSingleEvent(of: .value, with: { (assetSnap) in
                        if var assetData = assetSnap.value as? [String:Any] {
                            assetData["id"] = assetSnap.key as! String
                            self.setImageForCell(indexPath: indexPath, group: group, data: assetData)
                            
                            
                        }
                    })
                }
            }
        })
        
    }
    func setImageForCell(indexPath: IndexPath, group: Group, data: [String:Any]) {
        
        if data["thumbnail_url"] != nil {
            if let updateCell = self.collectionView?.cellForItem(at: indexPath) as? GroupCell {
                updateCell.imageView.loadImageUsingCacheWithUrlString(data["thumbnail_url"] as! String)
//                collectionView?.reloadItems(at: [indexPath])
                print("Setting image for VIDEO!")
                isImageUnread(id: data["id"] as! String, indexPath: indexPath)
            }
//            ImageCacheLoader().obtainImageWithPath(imagePath: data["thumbnail_url"] as! String) { (image) in
//                // Before assigning the image, check whether the current cell is visible for ensuring that it's right cell
//                if let updateCell = self.collectionView?.cellForItem(at: indexPath) as? GroupCell {
//                    updateCell.imageView.image = image
//                }
//            }
        } else {
            if let updateCell = self.collectionView?.cellForItem(at: indexPath) as? GroupCell {
                updateCell.imageView.loadImageUsingCacheWithUrlString(data["image_url"] as! String)
//                collectionView?.reloadItems(at: [indexPath])
                print("Setting image for IMAGE!")
                isImageUnread(id: data["id"]  as! String, indexPath: indexPath)
            }
//            ImageCacheLoader().obtainImageWithPath(imagePath: data["image_url"] as! String) { (image) in
//                // Before assigning the image, check whether the current cell is visible for ensuring that it's right cell
//                if let updateCell = self.collectionView?.cellForItem(at: indexPath) as? GroupCell {
//                    updateCell.imageView.image = image
//                }
//            }
        }

    }

    func isImageUnread(id: String, indexPath: IndexPath) {
        let ref = Database.database().reference().child("user-assets").child((self.user?.id!)!).child(id)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value as! Int == 0 {
                self.drawBlueBox(indexPath: indexPath)
            }
        }, withCancel: nil)
    }
    
    func drawBlueBox(indexPath: IndexPath) {
        if let updateCell = self.collectionView?.cellForItem(at: indexPath) as? GroupCell {
            updateCell.imageView.layer.borderWidth = 2
            let color = self.color(from: "0000FF")
            updateCell.imageView.layer.borderColor = color }
    }
    
    func color(from hexString : String) -> CGColor
    {
        if let rgbValue = UInt(hexString, radix: 16) {
            let red   =  CGFloat((rgbValue >> 16) & 0xff) / 255
            let green =  CGFloat((rgbValue >>  8) & 0xff) / 255
            let blue  =  CGFloat((rgbValue      ) & 0xff) / 255
            return UIColor(red: red, green: green, blue: blue, alpha: 1.0).cgColor
        } else {
            return UIColor.black.cgColor
        }
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
        if let updateCell = self.collectionView?.cellForItem(at: indexPath) as? GroupCell {
            updateCell.imageView.layer.borderWidth = 0
            updateCell.imageView.image = #imageLiteral(resourceName: "placeholder")
            updateCell.imageView.layer.borderColor = UIColor.blue.cgColor
            updateAssetsToRead(group_id: (updateCell.group?.id!)!)
        }
        
    
    }

    func updateAssetsToRead(group_id: String) {
        let ref = Database.database().reference().child("group-assets").child(group_id)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let data = snapshot.value as? [String:Any] {
                let group_keys = Array(data.keys)
                let newref = Database.database().reference().child("user-assets").child((self.user?.id!)!)
                
                newref.observeSingleEvent(of: .value, with: { (usersnap) in
                    if var data2 = snapshot.value as? [String:Any] {
                        let user_keys = Array(data2.keys)
                        let final_keys = group_keys.filter{ user_keys.contains($0) }
                        
                        self.updateKeys(array: final_keys)
                    }
                }, withCancel: nil)
            }
        }, withCancel: nil)
        // get all assets for group
        // get all user assets
        // keep only user assets that are from group
        // update each to read ( value to 1)
    }
    
    func updateKeys(array: [String]) {
        print("ARRAY!", array)
        for string in array {
            let ref = Database.database().reference().child("user-assets").child((self.user?.id!)!)
            ref.updateChildValues([string:1])
        }
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
                vc.user = self.user
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

typealias ImageCacheLoaderCompletionHandler = ((UIImage) -> ())

class ImageCacheLoader {
    
    var task: URLSessionDownloadTask!
    var session: URLSession!
    var cache: NSCache<NSString, UIImage>!
    
    init() {
        session = URLSession.shared
        task = URLSessionDownloadTask()
        self.cache = NSCache()
    }
    
    func obtainImageWithPath(imagePath: String, completionHandler: @escaping ImageCacheLoaderCompletionHandler) {
        if let image = self.cache.object(forKey: imagePath as NSString) {
            DispatchQueue.main.async {
                completionHandler(image)
            }
        } else {
            /* You need placeholder image in your assets,
             if you want to display a placeholder to user */
            //let placeholder = #imageLiteral(resourceName: "placeholder")
            DispatchQueue.main.async {
                // completionHandler(placeholder)
            }
            let url: URL! = URL(string: imagePath)
            task = session.downloadTask(with: url, completionHandler: { (location, response, error) in
                if let data = try? Data(contentsOf: url) {
                    let img: UIImage! = UIImage(data: data)
                    self.cache.setObject(img, forKey: imagePath as NSString)
                    DispatchQueue.main.async {
                        completionHandler(img)
                    }
                }
            })
            task.resume()
        }
    }
}

extension Array {
    func contains_test<T where T : Equatable>(obj: T) -> Bool {
        return self.filter({$0 as? T == obj}).count > 0
    }
}
extension UIColor {
    
    convenience init(rgbColorCodeRed red: Int, green: Int, blue: Int, alpha: CGFloat) {
        
        let redPart: CGFloat = CGFloat(red) / 255
        let greenPart: CGFloat = CGFloat(green) / 255
        let bluePart: CGFloat = CGFloat(blue) / 255
        
        self.init(red: redPart, green: greenPart, blue: bluePart, alpha: alpha)
        
    }
}

//

