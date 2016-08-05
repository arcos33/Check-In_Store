//
//  StylistsTableViewController.swift
//  ci-front
//
//  Created by Joel on 8/5/16.
//  Copyright © 2016 whitecoatlabs. All rights reserved.
//

import UIKit

class StylistsTableViewController: UITableViewController {
    
    var wirelessProviders: Array<String>!
    var didSetProvider:Bool!
    var providerSelected:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadProviders()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func loadProviders() {
        wirelessProviders = Array(arrayLiteral: "Juan", "Alicia", "Jose", "Raul", "Otro")
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
        let provider = wirelessProviders[indexPath.row] as String
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
        return wirelessProviders.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.didSetProvider = true
        let selection = self.wirelessProviders[indexPath.row]
        self.providerSelected = selection
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
