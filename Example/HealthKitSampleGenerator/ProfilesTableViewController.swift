//
//  ProfilesTableViewController.swift
//  HealthKitSampleGenerator
//
//  Created by Michael Seemann on 23.10.15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import HealthKitSampleGenerator

class ProfilesTableViewController: UITableViewController {
    

    var profiles:[HealthKitProfile] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem();
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let documentsUrl = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        profiles = HealthKitProfileReader.readProfilesFromDisk(documentsUrl)
        
        tableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // make sure the table view is not in editing mode
        if tableView.editing {
            tableView.setEditing(false, animated: true)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
        if segue.identifier == "detailView" {
            let detailViewController = segue.destinationViewController as! ImportProfileViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                 detailViewController.profile = profiles[indexPath.row]
            }
        }
    }
    
}

// TableView DataSource
extension ProfilesTableViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profiles.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let profile = profiles[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("profileCell")!
        
        cell.textLabel?.text = profile.fileName
        
        profile.loadMetaData(true) { (metaData:HealthKitProfileMetaData) in

            NSOperationQueue.mainQueue().addOperationWithBlock(){
                
                let from = UIUtil.sharedInstance.formatDate(metaData.creationDate)
                let profileName = metaData.profileName != nil ? metaData.profileName! : "unknown"
                
                cell.detailTextLabel?.text = "\(profileName) from: \(from)"
            }

        }
        return cell
        
    }
    
}

// UITableViewDelegate
extension ProfilesTableViewController {
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            let profile = profiles[indexPath.row]
            
            let alert = UIAlertController(
                            title: "Delete Profile \(profile.fileName)",
                            message: "Do you really want to delete this prolfile? The file will be deleted! This can not be undone!",
                            preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: "Yes, delete it!", style: .Destructive, handler: { action in
                do {
                    try profile.deleteFile()
                    self.profiles.removeAtIndex(indexPath.row)
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:.Automatic)
                } catch let error {
                    let errorAlert = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .Alert)
                    errorAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                    self.presentViewController(errorAlert, animated: true, completion: nil)
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
}