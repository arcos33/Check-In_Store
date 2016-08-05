//
//  StylistsTableViewController.swift
//  ci-front
//
//  Created by Joel on 8/5/16.
//  Copyright © 2016 whitecoatlabs. All rights reserved.
//

import UIKit

protocol StylistTableDelegate {
    func didSelectStylist(stylist: String)
}

class StylistsTableViewController: UITableViewController {
    
    var stylists: Array<String>!
    var didSetStylist:Bool!
    var stylistSelected:String!
    var delegate: StylistTableDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Try to get a cell
        let provider = self.stylists[indexPath.row] as String
        let cell = UITableViewCell()
        cell.textLabel?.text = provider
        cell.textLabel?.textAlignment = .Center
        return cell
    }
    
    // Other table view delegate/data source methods
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.stylists.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.didSetStylist = true
        let selection = self.stylists[indexPath.row]
        self.stylistSelected = selection
        self.dismissViewControllerAnimated(true, completion: nil)
        self.delegate?.didSelectStylist(selection)
    }
}
