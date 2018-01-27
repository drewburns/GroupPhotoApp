//
//  ChatConfirmViewController.swift
//  Wingman
//
//  Created by Andrew Burns on 9/3/17.
//  Copyright © 2017 Andrew Burns. All rights reserved.
//

import UIKit
import Firebase
import NotificationBannerSwift

class GroupConfirmViewController: UIViewController , UITextViewDelegate{
    var users:[AppUser] = []
    var user: AppUser?
    var nav: UINavigationController?
    let base = Database.database().reference()
    
    @IBOutlet weak var mainView: UIView!

    @IBOutlet weak var textInput: UITextView!
    @IBOutlet weak var sendMessageButton: UIButton!
    let reachability = Reachability()!
    var internet = ""
    
    
    func internetChanged(note: Notification) {
        
    }
    

    @IBAction func createGroup(_ sender: Any) {
        if textInput.text! != "" {
            makeGroupRecord()
            goBack()
        } else {
            // error need a name
        }
    }
    
    func makeGroupRecord() {
        let ref = Database.database().reference().child("groups").childByAutoId()
        let timestamp:Int = Int(NSDate().timeIntervalSince1970)
        ref.updateChildValues(["name" : textInput.text!, "timestamp": timestamp, "creation_date": timestamp], withCompletionBlock: {(err, reference) in
            if err == nil {
                for user in self.users {
                    let newref = Database.database().reference().child("group-users").child(ref.key)
                    newref.updateChildValues([user.id! : 0])
                    self.createUserGroup(path: reference.key, user: user)
                }
            } else {
                // there is an error
            }
        })
    
        
    }
    
    func createUserGroup(path: String, user: AppUser) {
        let newref = Database.database().reference().child("user-groups").child(user.id!)
        newref.updateChildValues([path : 0])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.users.append(self.user!)
        textInput.delegate = self
        mainView.layer.cornerRadius = 5;
        mainView.layer.masksToBounds = true;
        self.hideKeyboardWhenTappedAround()
        var downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)))
        downSwipe.direction = UISwipeGestureRecognizerDirection.down
        self.mainView.addGestureRecognizer(downSwipe)
        reachability.whenReachable = { _ in
            if self.internet == "unreachable" {
                DispatchQueue.main.async(execute: {
                    self.dismiss(animated: false, completion: nil)
                    // dismiss unreachable view
                })
                self.internet = ""
            }
            
        }
        
        reachability.whenUnreachable = {_ in
            self.internet = "unreachable"
            DispatchQueue.main.async(execute: {
                let alert = UIAlertController(title: nil, message: "Connect to Internet", preferredStyle: .alert)
                
                let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
                loadingIndicator.hidesWhenStopped = true
                loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
                loadingIndicator.startAnimating();
                
                alert.view.addSubview(loadingIndicator)
                self.present(alert, animated: true, completion: nil)
            })
        }
        NotificationCenter.default.addObserver(self, selector: #selector(internetChanged), name: ReachabilityChangedNotification, object: reachability)
        do {
            try reachability.startNotifier()
        } catch {
            // something went wrong
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    
    func goBack() {
        self.dismiss(animated: true, completion: {
            self.dismiss(animated: true, completion: nil)
            //        let presenting = self.presentedViewController
            //        let nav = presenting?.navigationController
            self.nav?.popToRootViewController(animated: true)
        })
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension UIImageView {
    public func maskCircle() {
        self.contentMode = UIViewContentMode.scaleAspectFill
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.masksToBounds = false
        self.clipsToBounds = true
        
        // make square(* must to make circle),
        // resize(reduce the kilobyte) and
        // fix rotation.
        //        self.image = anyImage
    }
}
