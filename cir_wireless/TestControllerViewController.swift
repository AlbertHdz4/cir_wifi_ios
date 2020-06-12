//
//  TestControllerViewController.swift
//  cir_wireless
//
//  Created by softel on 12/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

import UIKit

class TestControllerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var testTable: UITableView!
    
    @IBOutlet weak var courtain: CourtainView!
    let countries = ["ES", "MX", "ARG"]
    
 lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(handleRefresh(_:)),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.lightGray

        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testTable.refreshControl = self.refreshControl
        testTable.dataSource = self
        testTable.delegate = self
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "reusable")
        cell.textLabel?.text = countries[indexPath.row]
        return cell
    }
    
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        print("Refreshing ... ")
        refreshControl.endRefreshing()
    }
}
