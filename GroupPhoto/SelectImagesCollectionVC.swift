//
//  SelectImagesCollectionVC.swift
//  GroupPhoto
//
//  Created by Andrew Burns on 11/25/17.
//  Copyright © 2017 Andrew Burns. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "Cell"

class SelectImagesCollectionVC: UICollectionViewController {

    var imageArray = [UIImage]()
    var pickedImages = [UIImage]()
    
    func grapPhotos() {
        let imgManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .opportunistic
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",ascending: false)]
        
        if let fetchResult : PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions) {
            if fetchResult.count > 0 {
                for i in 0..<fetchResult.count {
                    imgManager.requestImage(for: fetchResult.object(at: i) as PHAsset, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill , options: requestOptions, resultHandler: { (image, error) in
                        self.imageArray.append(image!)
                    })
                }
            }
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        grapPhotos()
        print("))))))))))))))))))")
        print("IMAGE ARRAY", imageArray)
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        //Get device width
        let width = UIScreen.main.bounds.width
        
        //set section inset as per your requirement.
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0 , bottom: 0, right: 0 )
        
        //set cell item size here
        layout.itemSize = CGSize(width: width/3, height: width/3 )
        
        //set Minimum spacing between 2 items
        layout.minimumInteritemSpacing = 0
        
        //set minimum vertical line spacing here between two lines in collectionview
        layout.minimumLineSpacing = 0
        
        //apply defined layout to collectionview
        collectionView!.collectionViewLayout = layout
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
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
        return imageArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
//        cell.backgroundColor = UIColor.black
//        print("CELL THING", cell.viewWithTag(1))
//        var imageView = cell.viewWithTag(1) as! UIImageView
        
        let imageView = UIImageView(image: imageArray[indexPath.row])
        imageView.frame = CGRect(x: 0, y: 0, width: cell.bounds.width, height: cell.bounds.height)
        cell.addSubview(imageView)
        // Configure the cell
    
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let list = collectionView.indexPathsForSelectedItems {
            pickedImages.removeAll()
            let cell = collectionView.cellForItem(at: indexPath)
            cell?.layer.borderWidth = 3.0
            cell?.layer.borderColor = UIColor.blue.cgColor
            for item in list {
                self.pickedImages.append(self.imageArray[item.row])
            }

        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        // update list
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

}
