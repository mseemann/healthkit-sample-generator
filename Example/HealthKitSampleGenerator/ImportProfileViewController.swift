//
//  ImportProfileViewController.swift
//  HealthKitSampleGenerator
//
//  Created by Michael Seemann on 25.10.15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import HealthKitSampleGenerator

class ImportProfileViewController : UIViewController {
    
    @IBOutlet weak var lbProfileName: UILabel!
    @IBOutlet weak var lbCreationDate: UILabel!
    @IBOutlet weak var lbVersion: UILabel!
    @IBOutlet weak var lbType: UILabel!
    
    @IBOutlet weak var swDeleteExistingData: UISwitch!
    @IBOutlet weak var pvImportProgress: UIProgressView!
    @IBOutlet weak var lbImportProgress: UILabel!
    @IBOutlet weak var aiImporting: UIActivityIndicatorView!
    
    
    var profile: HealthKitProfile?
    
    var importing = false {
        didSet {
            pvImportProgress.hidden = !importing
            aiImporting.hidden = !importing
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.importing          = false
        lbProfileName.text      = ""
        lbCreationDate.text     = ""
        lbVersion.text          = ""
        lbType.text             = ""
        lbImportProgress.text   = ""
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        profile?.loadMetaData(true) { (metaData: HealthKitProfileMetaData) in
            NSOperationQueue.mainQueue().addOperationWithBlock(){
                self.lbProfileName.text = metaData.profileName
                self.lbCreationDate.text = UIUtil.sharedInstance.formatDate(metaData.creationDate)
                self.lbVersion.text = metaData.version
                self.lbType.text = metaData.type
            }
        }
    }
    
    
    @IBAction func doImport(sender: AnyObject) {
        importing = true
        lbImportProgress.text = "Start import"
    }
    
}