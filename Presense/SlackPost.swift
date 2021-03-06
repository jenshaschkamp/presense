//
//  SlackPost.swift
//  Presense
//
//  Created by Chay Choong on 21/3/16.
//  Copyright © 2016 SUTDiot. All rights reserved.
//

import UIKit
import Foundation
import CoreData

enum FieldError: ErrorType {
    case emptyName
    case invalidURL
    case beaconsNotFound
}

func sendMessage(message: String) throws {
    
    var err: String = ""
    let semaphore = dispatch_semaphore_create(0)
    
//    let payload = "payload={\"channel\": \"#presensetest\", \"username\": \"webhookbot\", \"icon_emoji\":\":calling:\", \"text\": \"\(message)\"}"
    let payload = "payload={\"user\": \"\(identity!.valueForKey("name") as! String)\", \"status\": \"\(message)\"}"
    let data = (payload as NSString).dataUsingEncoding(NSUTF8StringEncoding)
    if let url = NSURL(string: (identity!.valueForKey("url") as? String)!)
    {
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = data
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in

            if error != nil {
                err = ("error: \(error!.localizedDescription): \(error!.userInfo)")
                print(err)
            }
            else if data != nil {
                if let str = NSString(data: data!, encoding: NSUTF8StringEncoding) {
                    print("\(str)")
                }
                else {
                    err = ("error")
                }
            }
            dispatch_semaphore_signal(semaphore)
        }
        task.resume()
        
    }
    else {
        err = ("error")
    }
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    if (err != "") {
        throw FieldError.invalidURL
    }
}

func saveStatus(status: String) {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedContext = appDelegate.managedObjectContext
    
    let fetchRequest = NSFetchRequest(entityName: "SlackData")
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
    fetchRequest.fetchLimit = 1
    
    
    do {
        
        let result = try managedContext.executeFetchRequest(fetchRequest)
        let count = result.count
        let entity =  NSEntityDescription.entityForName("SlackData", inManagedObjectContext:managedContext)
        var webhookURL = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        if (count > 0) {
            webhookURL = result[0] as! NSManagedObject
        }
        
        webhookURL.setValue(status, forKey: "status")
        
        try webhookURL.managedObjectContext?.save()
        print("Status changed to \(status)")
        
        identity = webhookURL
        
    } catch let error as NSError {
        print("Could not fetch \(error), \(error.userInfo)")
    }
}
