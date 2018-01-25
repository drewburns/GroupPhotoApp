//
//  ShareViewController.swift
//  GroupPhotoShare
//
//  Created by Andrew Burns on 12/25/17.
//  Copyright © 2017 Andrew Burns. All rights reserved.
//

import UIKit
import Social



class ShareViewController: SLComposeServiceViewController {

    override func viewDidLoad() {
        self.title = "GroupPhoto"
    }
    override func viewDidAppear(_ animated: Bool) {
        print("SUBVIEWS")
        //print(self.view.subviews[0])
        //print(self.view.subviews[2].subviews[3].subviews[0].subviews[0].subviews[0].subviews)
        //print("_________________")
        //self.view.subviews[2].subviews[3].subviews[0].subviews[0].subviews[0].subviews[4].removeFromSuperview()
    }
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        //print("_______CONTEXT_________")
        //print(extensionContext)
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        if let deck = SLComposeSheetConfigurationItem() {
            deck.title = "Selected Deck"
            deck.value = "Deck Title"
            deck.tapHandler = {
                // on tap
            }
            return [deck]
        }
        return nil
    }

}
