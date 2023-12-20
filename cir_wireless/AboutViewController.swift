//
//  AboutControllerViewController.swift
//  cir_wireless
//
//  Created by softel on 17/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var versionLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nsObject = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject?
        let version = nsObject as? String ?? "no available"
        let vrs = NSLocalizedString("Version", comment: "App version")
        versionLabel.text = "\(vrs): \(version)"
    }

}
