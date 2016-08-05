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
    var appDelegate:AppDelegate!
    var stylists = Array<String>()
    var servicesOffered = Array<String>()
    var checkinEvent: CheckinEvent?
    var serviceSelected: String?
    var stylistSelected: String?
    
    //------------------------------------------------------------------------------
    // MARK: Lifecycle Methods
    //------------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        getStylists()
        NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: #selector(getStylists), userInfo: nil, repeats: true)
        getServices()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func getStylists() {
        let url:NSURL = NSURL(string: "http://whitecoatlabs.co/checkin/develop/mobile_api/Get/get_stylists.php")!
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = .ReloadIgnoringLocalCacheData
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let task = session.dataTaskWithRequest(request) {(let data, let response, let error) in
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("error = \(error)")
                return
            }
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                for object in json as! [Dictionary<String, String>] {
                    if !self.stylists.contains(object["name"]!) {
                        self.stylists.append(object["name"]!)
                    }
                }
            }
            catch {
                print("error: \(error)")
            }
        }
        task.resume()
    }
    
    func getServices() {
        let url:NSURL = NSURL(string: "http://whitecoatlabs.co/checkin/develop/mobile_api/Get/get_services.php")!
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = .ReloadIgnoringLocalCacheData
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let task = session.dataTaskWithRequest(request) {(let data, let response, let error) in
            guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                print("error = \(error)")
                return
            }
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                for object in json as! [Dictionary<String, String>] {
                    self.servicesOffered.append(object["name"]!)
                }
            }
            catch {
                print("error: \(error)")
            }
        }
        task.resume()

    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "stylistListSegue" {
            self.stylistTable = segue.destinationViewController as? StylistsTableViewController
            self.stylistTable?.delegate = self
            self.stylistTable?.stylists = self.stylists
        }
        else {
            self.servicesTable = segue.destinationViewController as? ServicesOfferedTableViewController
            self.servicesTable?.delegate = self
            self.servicesTable?.servicesOffered = self.servicesOffered
        }
    }
    
    //------------------------------------------------------------------------------
    // MARK: Action Methods
    //-------------------------------------------------------------------------
    @IBAction func submit(sender: AnyObject) {
        print(self.stylistTable?.didSetStylist)
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
                // DEVELOP
                let url:NSURL = NSURL(string: "http://whitecoatlabs.co/checkin/develop/mobile_api/post_checkinEvent.php")!

                // LIVE
                //let url:NSURL = NSURL(string: "http://www.whitecoatlabs.co/checkin/glamour/mobile_api/post_checkinEvent.php")!
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
                
                let requestString = "checkinTimestamp=\(tempCheckinTime)&completedTimestamp=\(tempCompletedTimestamp)&name=\(self.checkinEvent!.name!)&phone=\(tempCleanString3!)&status=\(self.checkinEvent!.status!)&stylist=\(self.checkinEvent!.stylist!)&service=\(self.checkinEvent!.service!)" .dataUsingEncoding(NSUTF8StringEncoding)
                
                let task = session.uploadTaskWithRequest(request, fromData: requestString, completionHandler: { (data, response, error) in
                    guard let _:NSData = data, let _:NSURLResponse = response where error == nil else {
                        print(error)
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
                print("error:\(error)")
                
            }
        }
    }
    
    func resetUI() {
        self.nameTextField.text = nil
        self.phoneTextField.text = nil
        self.stylistButton.setTitle("elija Estilista", forState: .Normal)
        self.stylistButton.setTitleColor(UIColor(red: 0.84, green: 0.84, blue: 0.86, alpha: 1.00), forState: .Normal)
        self.servicesButton.setTitleColor(UIColor(red: 0.84, green: 0.84, blue: 0.86, alpha: 1.00), forState: .Normal)
        self.servicesButton.setTitle("elija Servicio", forState: .Normal)
        self.nameTextField.resignFirstResponder()
        self.phoneTextField.resignFirstResponder()
    }
    
    func formIsComplete() -> Bool {
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
    
    func presentAlert(message: String) {
        let alert = UIAlertController(title: "Falta informacion", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
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
    
    // MARK: StylistsTableDelegate methods
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