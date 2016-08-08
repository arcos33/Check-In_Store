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
    
    var services = [Service]()
    var didSetProvider:Bool!
    var providerSelected:String!
    var delegate: ServicesOfferedTableDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateTableFromNotification) , name: "CheckinVCDidReceiveServicesNotification", object: nil)
    }
    
    func updateTableFromNotification(notification: NSNotification) {
        self.services = notification.object! as! [Service]
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
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
        let service = self.services[indexPath.row] as Service
        let cell = UITableViewCell()
        cell.textLabel?.text = service.name
        cell.textLabel?.textAlignment = .Center
        return cell
    }
    
    // Other table view delegate/data source methods
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.services.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.didSetProvider = true
        let service = self.services[indexPath.row]
        self.providerSelected = service.name
        self.dismissViewControllerAnimated(true, completion: nil)
        self.delegate?.didSelectService(service.name)
    }
}
