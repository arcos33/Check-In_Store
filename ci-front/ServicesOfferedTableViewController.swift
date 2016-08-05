//
//  ServicesOfferedTableViewController.swift
//  ci-front
//
//  Created by Joel on 8/5/16.
//  Copyright © 2016 whitecoatlabs. All rights reserved.
//

import UIKit

protocol ServicesOfferedTableDelegate {
    func didSelectService(service: String)
}

class ServicesOfferedTableViewController: UITableViewController {
    
    var servicesOffered: Array<String>!
    var didSetProvider:Bool!
    var providerSelected:String!
    var delegate: ServicesOfferedTableDelegate?
    
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
        let provider = self.servicesOffered[indexPath.row] as String
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
        return self.servicesOffered.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.didSetProvider = true
        let selection = self.servicesOffered[indexPath.row]
        self.providerSelected = selection
        self.dismissViewControllerAnimated(true, completion: nil)
        self.delegate?.didSelectService(selection)
    }
}
