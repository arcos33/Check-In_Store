//
//  CheckInViewController.swift
//  CheckIn-Store
//
//  Created by Joel on 7/27/16.
//  Copyright © 2016 whitecoatlabs. All rights reserved.
//

import UIKit
import CoreData

class CheckInViewController: UIViewController {
    
    @IBOutlet var phoneTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!
    
    //var wpvc:WirelessProvidersTableViewController?
    var appDelegate:AppDelegate!
    
    //------------------------------------------------------------------------------
    // MARK: Lifecycle Methods
    //------------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        self.wpvc = segue.destinationViewController as? WirelessProvidersTableViewController
//        self.wpvc!.preferredContentSize = CGSizeMake(200, 360)
//        self.wpvc!.didSetProvider = true;
    }
    
    //------------------------------------------------------------------------------
    // MARK: Action Methods
    //-------------------------------------------------------------------------
    @IBAction func submit(sender: AnyObject) {
        
        if (formIsComplete()) {
            let checkinEvent = NSEntityDescription.insertNewObjectForEntityForName("CheckinEvent", inManagedObjectContext: self.appDelegate.managedObjectContext) as! CheckinEvent
            
            checkinEvent.uniqueID = NSUserDefaults.standardUserDefaults().createUniqueID()
            checkinEvent.checkinTimestamp = NSDate()
            checkinEvent.completedTimestamp = NSDate(timeIntervalSince1970: 0)
            checkinEvent.name = nameTextField.text
            checkinEvent.phone = phoneTextField.text
            //checkinEvent.wirelessProvider = self.wpvc?.providerSelected
            let tempCleanString1 = checkinEvent.phone?.stringByReplacingOccurrencesOfString("(", withString: "")
            let tempCleanString2 = tempCleanString1?.stringByReplacingOccurrencesOfString(")", withString: "")
            let tempCleanString3 = tempCleanString2?.stringByReplacingOccurrencesOfString("-", withString: "")
            checkinEvent.status = "checkedin"
            
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
                let tempCheckinTime = dateFormatter.stringFromDate(checkinEvent.checkinTimestamp!)
                let tempCompletedTimestamp = dateFormatter.stringFromDate(checkinEvent.completedTimestamp!)
                
                let jsonData = "checkinTimestamp=\(tempCheckinTime)&completedTimestamp=\(tempCompletedTimestamp)&name=\(checkinEvent.name!)&phone=\(tempCleanString3!)&status=\(checkinEvent.status!)" .dataUsingEncoding(NSUTF8StringEncoding)
                
                let task = session.uploadTaskWithRequest(request, fromData: jsonData, completionHandler: { (data, response, error) in
                    guard let _:NSData = data, let _:NSURLResponse = response where error == nil else {
                        print(error)
                        return
                    }
                    
                    let responseBody = String(data: data!, encoding: NSUTF8StringEncoding)
                    print(responseBody)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.clearTextFields()
                    })
                })
                task.resume()
            }
            catch {
                print("error:\(error)")
                
            }
        }
    }
    
    func clearTextFields() {
        self.nameTextField.text = nil
        self.phoneTextField.text = nil
        self.nameTextField.resignFirstResponder()
        self.phoneTextField.resignFirstResponder()
    }
    
    func formIsComplete() -> Bool {
        if nameTextField.text?.characters.count == 0 {
            presentAlert("Ingrese nombre")
            return false
        }
        else if phoneTextField.text?.characters.count != 13 {
            presentAlert("Ingrese numero telefonico valido")
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
}