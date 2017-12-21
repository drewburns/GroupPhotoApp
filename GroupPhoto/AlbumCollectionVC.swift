//
//  AlbumCollectionVC.swift
//  GroupPhoto
//
//  Created by Andrew Burns on 11/29/17.
//  Copyright © 2017 Andrew Burns. All rights reserved.
//

import UIKit
import Firebase
import AVKit
import AVFoundation
import MediaPlayer

private let reuseIdentifier = "Cell"

class AlbumCollectionVC: UICollectionViewController {

    var group:Group?
    var assets:[Asset] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchGroupAssets()
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        //Get device width
        let width = UIScreen.main.bounds.width
        
        //set section inset as per your requirement.
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0 , bottom: 0, right: 0 )
        
        //set cell item size here
        layout.itemSize = CGSize(width: width / 4, height: width/4)
        
        //set Minimum spacing between 2 items
        layout.minimumInteritemSpacing = 0
        
        //set minimum vertical line spacing here between two lines in collectionview
        layout.minimumLineSpacing = 0
        
        //apply defined layout to collectionview
        collectionView!.collectionViewLayout = layout
        
        

        
//        print(group!.name)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchGroupAssets() {
        let ref = Database.database().reference().child("group-assets").child((group?.id!)!)
        ref.observe(.childAdded, with: {(snapshot) in
            if snapshot.exists() {
                self.fetchAsset(key: snapshot.key)
            }
        
        })
        
        
        
        
    }
    
    func fetchAsset(key: String) {
        let ref = Database.database().reference().child("assets").child(key)
        ref.observeSingleEvent(of: .value, with: {(snapshot) in
            if var data = snapshot.value as? [String:Any] {
                data["id"] = snapshot.key
                let asset = Asset()
                asset.setValuesForKeys(data)
                print("ASSET BEING MADE!", asset)
                self.assets.append(asset)
//                self.assets.sort { Float($0.timestamp!) < Float($1.timestamp!) }
                DispatchQueue.main.async(execute: {
                    
                    self.collectionView?.reloadData()
                })
            }
        })
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
        return assets.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! AssetCell
//        print("CELL BEING MADE")
        cell.backgroundColor = UIColor.black
        cell.asset = assets[indexPath.row]
        let userImage = cell.imageView
//        userImage.tag =
        
        // let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
//        tapGestureRecognizer.
       //  userImage?.isUserInteractionEnabled = true
        // userImage?.addGestureRecognizer(tapGestureRecognizer)
        
        // Configure the cell
    
        return cell
    }
    

    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        //        let tappedImage = tapGestureRecognizer.view as! UIImageView
        
        //
    }
    
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    func performZoomInForStartingImageView(_ startingImageView: UIImageView, _ staringNumber: Int) {
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        print("STARTING FRAME")
        print(startingFrame?.origin.x)
        print((self.view.bounds.width/2))
        
        let zoomingScrollView = UIScrollView(frame: (self.collectionView?.frame)!)
        zoomingScrollView.backgroundColor = UIColor.black
        for i in 0..<assets.count{
            let imageView = UIImageView()
            if assets[i].thumbnail_url != nil {
                imageView.loadImageUsingCacheWithUrlString(assets[i].thumbnail_url!)
                imageView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
                // for now because video was sideways???
                // load other video stuff
            } else {
                imageView.loadImageUsingCacheWithUrlString(assets[i].image_url!)
            }
            let xPosition = (self.collectionView?.frame.width)! * CGFloat(i)
            zoomingScrollView.isPagingEnabled = true
            zoomingScrollView.contentSize.width = zoomingScrollView.frame.width * CGFloat(i+1)
            imageView.frame = CGRect(x: xPosition, y: 0, width: zoomingScrollView.frame.width, height: zoomingScrollView.frame.height)
            imageView.contentMode = .scaleAspectFill
            imageView.isUserInteractionEnabled = true
            if assets[i].thumbnail_url != nil {
                let newView = CustomImageView(image: #imageLiteral(resourceName: "playbutton"))
                newView.transform = CGAffineTransform(rotationAngle: (3)*CGFloat(M_PI_2))
                newView.frame = CGRect(x: 150, y:150, width: 150, height: 150)
                newView.isUserInteractionEnabled = true
                newView.url = assets[i].video_url
                newView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePlayVideo)))
                imageView.addSubview(newView)
            }
            zoomingScrollView.addSubview(imageView)
            let startingX = zoomingScrollView.frame.width * CGFloat(staringNumber)
            zoomingScrollView.contentOffset = CGPoint(x: startingX ,y :0)
            // find the amount to offset
        }

        
        zoomingScrollView.isUserInteractionEnabled = true
        zoomingScrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleZoomOut))
        downSwipe.direction = UISwipeGestureRecognizerDirection.down
        zoomingScrollView.addGestureRecognizer(downSwipe)
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleZoomOut))
        upSwipe.direction = UISwipeGestureRecognizerDirection.up
        zoomingScrollView.addGestureRecognizer(upSwipe)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.black
        zoomingImageView.contentMode = .scaleAspectFill
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        
        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
            
            keyWindow.addSubview(zoomingScrollView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackBackgroundView?.alpha = 1
                self.view.alpha = 0
                
                // math?
                // h2 / w1 = h1 / w1
                // h2 = h1 / w1 * w1
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                
                zoomingImageView.center = keyWindow.center
                
            }, completion: { (completed) in
                //                    do nothing
            })
            
        }
    }
    
    
    func handleZoomOut(_ tapGesture: UISwipeGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            //need to animate back out to controller
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.view.alpha = 1
                
            }, completion: { (completed) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
        }
    }
    
    func handlePlayVideo(_ tapGesture: UITapGestureRecognizer) {
        if let imageView = tapGesture.view as? CustomImageView{
            let player = AVPlayer(url: URL(string: imageView.url)!)
            let playerController = AVPlayerViewController()
            playerController.player = player
            self.present(playerController, animated: true) {
                player.play()
            }
        }

    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! AssetCell
        performZoomInForStartingImageView(cell.imageView as! UIImageView, indexPath.row)
        // load scroll view 
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
    
    // CODE FOR VIDEO PLAYING
    


}
class CustomImageView: UIImageView {
    var url:String!
    
}
