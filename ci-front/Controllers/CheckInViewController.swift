//
//  CheckInViewController.swift
//  CheckIn-Store
//
//  Created by Joel on 7/27/16.
//  Copyright © 2016 whitecoatlabs. All rights reserved.
//

import UIKit
import CoreData

class CheckInViewController: UIViewController, StylistTableDelegate, ServicesOfferedTableDelegate {
    
    @IBOutlet var phoneTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var stylistButton: UIButton!
    @IBOutlet var servicesButton: UIButton!
    
    var stylistTable:StylistsTableViewController?
    var servicesTable:ServicesOfferedTableViewController?
    var checkinEvent: CheckinEvent?
    var serviceSelected: String?
    var stylistSelected: String?
    var stylists = [Stylist]()
    var stylistMapping = Dictionary<String, AnyObject>()
    var services = [Service]()
    var serviceMapping = Dictionary<String, AnyObject>()
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    //------------------------------------------------------------------------------
    // MARK: Lifecycle Methods
    //------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        getStylists()
        NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: #selector(getStylists), userInfo: nil, repeats: true)
        getServices()
        NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: #selector(getServices), userInfo: nil, repeats: true)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.nameTextField.resignFirstResponder()
        self.phoneTextField.resignFirstResponder()
        if segue.identifier == "stylistListSegue" {
            self.stylistTable = segue.destinationViewController as? StylistsTableViewController
            self.stylistTable?.delegate = self
            self.stylistTable?.stylists = self.stylists
        }
        else {
            self.servicesTable = segue.destinationViewController as? ServicesOfferedTableViewController
            self.servicesTable?.delegate = self
            self.servicesTable?.services = self.services
        }
    }
    
    //------------------------------------------------------------------------------
    // MARK: Private Methods
    //------------------------------------------------------------------------------
    @objc private func getStylists() {
        let url:NSURL = NSURL(string: "http://whitecoatlabs.co/checkin/\(self.appDelegate.user)/mobile_api/get/get_stylists.php")!
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = .ReloadIgnoringLocalCacheData
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let task = session.dataTaskWithRequest(request) {(let data, let response, let error) in
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                return
            }
            do {
                let jsonResponseString = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                let responseBody = String(data: data!, encoding: NSUTF8StringEncoding)
                if responseBody != "null" {
                    for object in jsonResponseString as! [Dictionary<String, String>] {
                        let stylist = Stylist(status: object["status"]!, id: object["id"]!, name: object["name"]!)
                        if (self.stylistMapping[object["id"]!] == nil) {
                            let objectID = object["id"]!
                            self.stylistMapping[objectID] = stylist
                        }
                        else { // update it
                            stylist.status = object["status"]
                            self.stylistMapping[object["id"]!] = stylist
                        }
                    }
                    var origIdArray = Array<String>()
                    for stylist in self.stylists {
                        origIdArray.append(stylist.id)
                    }
                    
                    self.stylists = []
                    for (_, value) in self.stylistMapping {
                        let stylist = value as! Stylist
                        if stylist.status == "available" {
                            self.stylists.append(stylist)
                        }
                    }
                    var newIdArray = Array<String>()
                    for stylist in self.stylists {
                        newIdArray.append(stylist.id)
                    }
                    
                    if origIdArray != newIdArray {
                        NSNotificationCenter.defaultCenter().postNotificationName("CheckinVCDidReceiveStylistsNotification", object: self.stylists)
                        origIdArray = []
                        newIdArray = []
                    }
                    
                }
            }
            catch {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
            }
        }
        task.resume()
    }
    
    @objc private func getServices() {
        let url:NSURL = NSURL(string: "http://whitecoatlabs.co/checkin/\(self.appDelegate.user)/mobile_api/get/get_services.php")!
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = .ReloadIgnoringLocalCacheData
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let task = session.dataTaskWithRequest(request) {(let data, let response, let error) in
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                return
            }
            do {
                let responseBody = String(data: data!, encoding: NSUTF8StringEncoding)
                if responseBody != "null" {
                    let jsonResponseString = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                    for object in jsonResponseString as! [Dictionary<String, String>] {
                        let service = Service(name: object["name"]!, id: object["id"]!, status: object["status"]!)
                        if (self.serviceMapping[object["id"]!] == nil) {
                            self.serviceMapping[object["id"]!] = service
                        }
                        else { // update it
                            service.status = object["status"]
                            self.serviceMapping[object["id"]!] = service
                        }
                    }
                    var origIdArray = Array<String>()
                    for service in self.services {
                        origIdArray.append(service.id)
                    }
                    
                    self.services = []
                    for (_, value) in self.serviceMapping {
                        let service = value as! Service
                        if service.status == "available" {
                            self.services.append(service)
                        }
                    }
                    var newIdArray = Array<String>()
                    for service in self.services {
                        newIdArray.append(service.id)
                    }
                    
                    if origIdArray != newIdArray {
                        NSNotificationCenter.defaultCenter().postNotificationName("CheckinVCDidReceiveServicesNotification", object: self.services)
                        origIdArray = []
                        newIdArray = []
                    }
                }
                
            }
            catch {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
            }
        }
        task.resume()
        
    }
    
    private func resetUI() {
        self.nameTextField.text = nil
        self.phoneTextField.text = nil
        self.stylistButton.setTitle("elija Estilista", forState: .Normal)
        self.stylistButton.setTitleColor(UIColor(red: 0.84, green: 0.84, blue: 0.86, alpha: 1.00), forState: .Normal)
        self.servicesButton.setTitleColor(UIColor(red: 0.84, green: 0.84, blue: 0.86, alpha: 1.00), forState: .Normal)
        self.servicesButton.setTitle("elija Servicio", forState: .Normal)
        self.nameTextField.resignFirstResponder()
        self.phoneTextField.resignFirstResponder()
    }
    
    private func formIsComplete() -> Bool {
        if self.nameTextField.text?.characters.count == 0 {
            presentAlert("Ingrese nombre")
            return false
        }
        else if self.phoneTextField.text?.characters.count != 13 {
            presentAlert("Ingrese numero telefonico valido")
            return false
        }
        else if self.serviceSelected == nil {
            presentAlert("Elija un servicio")
            return false
        }
        else {
            return true
        }
    }
    
    private  func presentAlert(message: String) {
        let alert = UIAlertController(title: "Falta informacion", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    
    //------------------------------------------------------------------------------
    // MARK: Action Methods
    //------------------------------------------------------------------------------
    @IBAction func submit(sender: AnyObject) {
        if (formIsComplete()) {
            self.checkinEvent = NSEntityDescription.insertNewObjectForEntityForName("CheckinEvent", inManagedObjectContext: self.appDelegate.managedObjectContext) as? CheckinEvent
            
            self.checkinEvent!.uniqueID = NSUserDefaults.standardUserDefaults().createUniqueID()
            self.checkinEvent!.checkinTimestamp = NSDate()
            self.checkinEvent!.completedTimestamp = NSDate(timeIntervalSince1970: 0)
            self.checkinEvent!.name = nameTextField.text
            self.checkinEvent!.phone = phoneTextField.text
            self.checkinEvent!.stylist = self.stylistSelected
            self.checkinEvent!.service = self.serviceSelected
            
            let tempCleanString1 = self.checkinEvent!.phone?.stringByReplacingOccurrencesOfString("(", withString: "")
            let tempCleanString2 = tempCleanString1?.stringByReplacingOccurrencesOfString(")", withString: "")
            let tempCleanString3 = tempCleanString2?.stringByReplacingOccurrencesOfString("-", withString: "")
            self.checkinEvent!.status = "checkedin"
            
            do {
                try self.appDelegate.managedObjectContext.save()
                let url:NSURL = NSURL(string: "http://whitecoatlabs.co/checkin/\(self.appDelegate.user)/mobile_api/create/create_checkinEvent.php")!
                
                let session = NSURLSession.sharedSession()
                let request = NSMutableURLRequest(URL: url)
                request.HTTPMethod = "POST"
                request.cachePolicy = .ReloadIgnoringLocalCacheData
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let tempCheckinTime = dateFormatter.stringFromDate(self.checkinEvent!.checkinTimestamp!)
                let tempCompletedTimestamp = dateFormatter.stringFromDate(self.checkinEvent!.completedTimestamp!)
                
                if self.checkinEvent!.stylist == nil {
                    self.checkinEvent!.stylist = "sin preferencia"
                }
                
                let jsonRequestString = "checkinTimestamp=\(tempCheckinTime)&completedTimestamp=\(tempCompletedTimestamp)&name=\(self.checkinEvent!.name!)&phone=\(tempCleanString3!)&status=\(self.checkinEvent!.status!)&stylist=\(self.checkinEvent!.stylist!)&service=\(self.checkinEvent!.service!)" .dataUsingEncoding(NSUTF8StringEncoding)
                
                let task = session.uploadTaskWithRequest(request, fromData: jsonRequestString, completionHandler: { (data, response, error) in
                    guard let _:NSData = data, let _:NSURLResponse = response where error == nil else {
                        print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                        return
                    }
                    
                    let responseBody = String(data: data!, encoding: NSUTF8StringEncoding)
                    print(responseBody)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.resetUI()
                    })
                })
                task.resume()
            }
            catch {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
            }
        }
    }
    
    //------------------------------------------------------------------------------
    // MARK: UITextField Delegate Methods
    //------------------------------------------------------------------------------
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        if textField == self.phoneTextField
        {
            let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
            let components = newString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
            let decimalString = components.joinWithSeparator("") as NSString
            
            let length = decimalString.length
            let hasLeadingOne = length > 0 && decimalString.characterAtIndex(0) == (1 as unichar)
            
            if length == 0 || (length > 10 && !hasLeadingOne) || length > 11
            {
                let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
                
                return (newLength > 10) ? false : true
            }
            var index = 0 as Int
            let formattedString = NSMutableString()
            
            if hasLeadingOne
            {
                formattedString.appendString("1 ")
                index += 1
            }
            if (length - index) > 3
            {
                let areaCode = decimalString.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("(%@)", areaCode)
                index += 3
            }
            if length - index > 3
            {
                let prefix = decimalString.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("%@-", prefix)
                index += 3
            }
            
            let remainder = decimalString.substringFromIndex(index)
            formattedString.appendString(remainder)
            textField.text = formattedString as String
            
            return false
        }
        else
        {
            return true
        }
    }
    
    //------------------------------------------------------------------------------
    // MARK: StylistsTableDelegate methods
    //------------------------------------------------------------------------------
    func didSelectStylist(stylist: String) {
        self.stylistButton.setTitle(stylist, forState: .Normal)
        self.stylistButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.stylistSelected = stylist
    }
    
    // MARK: ServicesOfferedTableDelegate methods
    func didSelectService(service: String) {
        self.servicesButton.setTitle(service, forState: .Normal)
        self.servicesButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.serviceSelected = service
    }
}

class Stylist: NSObject {
    var status: String!
    var id: String!
    var name: String!
    
    init(status: String, id: String, name: String) {
        self.status = status
        self.id = id
        self.name = name
    }
}

class Service: NSObject {
    var name: String!
    var id: String!
    var status: String!
    
    init(name: String, id: String, status: String) {
        self.name = name
        self.id = id
        self.status = status
    }
}