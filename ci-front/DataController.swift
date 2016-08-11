//
//  DataController.swift
//  ci-front
//
//  Created by Joel on 8/10/16.
//  Copyright © 2016 whitecoatlabs. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class DataController: NSObject {
    static let sharedInstance = DataController()
    
    //var managedObjectContext: NSManagedObjectContext
    
    override private init() {} // This prevents others from using the default '()' initializer for this class.
    /*
     override init() {
     // This resource is the same name as your xcdatamodeld contained in your project.
     guard let modelURL = NSBundle.mainBundle().URLForResource("ClientOrganizerDataModel", withExtension:"momd") else {
     fatalError("Error loading model from bundle")
     }
     // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
     guard let mom = NSManagedObjectModel(contentsOfURL: modelURL) else {
     fatalError("Error initializing mom from: \(modelURL)")
     }
     let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
     self.managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
     self.managedObjectContext.persistentStoreCoordinator = psc
     let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
     let docURL = urls[urls.endIndex-1]
     /* The directory the application uses to store the Core Data store file.
     This code uses a file named "DataModel.sqlite" in the application's documents directory.
     */
     let storeURL = docURL.URLByAppendingPathComponent("ClientOrganizerDataModel.sqlite")
     do {
     try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
     } catch {
     fatalError("Error migrating store: \(error)")
     }
     }
     */
    
    func setURLIdentifierForUser(user: String) {
        let url: NSURL = NSURL(string: "http://whitecoatlabs.co/checkin/company_mapping.php")!
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.cachePolicy = .ReloadIgnoringLocalCacheData
        
        let jsonRequest = "username=\(user)".dataUsingEncoding(NSUTF8StringEncoding)
        let task = session.uploadTaskWithRequest(request, fromData: jsonRequest) { (data, response, error) in
            guard let data: NSData = data, let _:NSURLResponse = response where error == nil else {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
                return
            }
            
            do {
                let jsonResponse = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! [Dictionary<String, String>]
                for dict in jsonResponse {
                    let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appdelegate.user = dict["baseURL"]!
                    NSNotificationCenter.defaultCenter().postNotificationName("didSetUser", object: nil)
                }
            }
            catch {
                print("Class:\(#file)\n Line:\(#line)\n Error:\(error)")
            }
            
            //            let responseBody = String(data: data, encoding: NSUTF8StringEncoding)
            //            print(responseBody)
        }
        task.resume()
    }
}