//
//  MoreSettingsViewController.swift
//  FHS
//
//  Created by Daniel Bevenius on 05/08/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import UIKit

public class MoreSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    public var settings: Settings!
    var storeNames = [String]()
    public let tableCell = "tableCell"

    public override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func doneAction(sender: UIBarButtonItem) {
        navigationController?.popToRootViewControllerAnimated(false)
    }

    public func settings(settings: Settings) {
        self.settings = settings
        storeNames = Settings.findAllStores()
    }

    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        performSegueWithIdentifier("unwindToMain", sender: self)
    }

    public override func viewControllerForUnwindSegueAction(action: Selector, fromViewController: UIViewController, withSender sender: AnyObject?) -> UIViewController? {
        print("action \(action) fromViewController=\(fromViewController)")
        return self.parentViewController
    }

    public func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let _ = storeNames[indexPath.row]
    }

    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storeNames.count
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(tableCell, forIndexPath: indexPath)
        let name = storeNames[indexPath.row]
        cell.textLabel!.text = name
        cell.textLabel!.textColor = UIColor.whiteColor()
        if settings.stores.contains(name) {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            print("Yes, settings contains store \(name)")
        }
        return cell;
    }

    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storeName = storeNames[indexPath.row]
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        if cell.accessoryType == UITableViewCellAccessoryType.None {
            Settings.addStore(storeName)
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            Settings.removeStore(storeName)
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}
