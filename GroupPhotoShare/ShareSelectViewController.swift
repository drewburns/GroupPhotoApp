//
//  ShareSelectViewController.swift
//  GroupPhoto
//
//  Created by Andrew Burns on 12/27/17.
//  Copyright © 2017 Andrew Burns. All rights reserved.
//

import UIKit

class ShareSelectViewController: UIViewController {
    var userGroups = [Group]()
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: self.view.frame)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Identifiers.DeckCell)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        title = "Select Deck"
        view.addSubview(tableView)
    }
    // ...
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
private extension ShareSelectViewController {
    struct Identifiers {
        static let DeckCell = "deckCell"
    }
}
extension ShareSelectViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userGroups.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.DeckCell, for: indexPath)
        cell.textLabel?.text = userGroups[indexPath.row].name
        cell.backgroundColor = .clear
        return cell
    }
}
final class Group {
    var id: String?
    var name: String?
}
