//
//  MoreSettingsViewController.swift
//  FHS
//
//  Created by Daniel Bevenius on 05/08/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import UIKit

open class MoreSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    open var settings: Settings!
    var storeNames = [String]()
    open let tableCell = "tableCell"

    open override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func doneAction(_ sender: UIBarButtonItem) {
        navigationController?.popToRootViewController(animated: false)
    }

    open func settings(_ settings: Settings) {
        self.settings = settings
        storeNames = Settings.findAllStores()
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        performSegue(withIdentifier: "unwindToMain", sender: self)
    }

    open override func forUnwindSegueAction(_ action: Selector, from fromViewController: UIViewController, withSender sender: Any?) -> UIViewController? {
        print("action \(action) fromViewController=\(fromViewController)")
        return self.parent
    }

    open func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let _ = storeNames[indexPath.row]
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storeNames.count
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableCell, for: indexPath)
        let name = storeNames[indexPath.row]
        cell.textLabel!.text = name
        cell.textLabel!.textColor = UIColor.white
        if settings.stores.contains(name) {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
            print("Yes, settings contains store \(name)")
        }
        return cell;
    }

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storeName = storeNames[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath)!
        if cell.accessoryType == UITableViewCellAccessoryType.none {
            Settings.addStore(storeName)
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            Settings.removeStore(storeName)
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
