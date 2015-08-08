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
    var dataStoreNames = [String]()
    public let tableCell = "tableCell"

    public override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func doneAction(sender: UIBarButtonItem) {
        navigationController?.popToRootViewControllerAnimated(false)
    }

    public func settings(settings: Settings) {
        self.settings = settings
        dataStoreNames = Settings.findAllStores()
        println(settings.stores)

    }

    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        performSegueWithIdentifier("unwindToMain", sender: self)
    }

    public override func viewControllerForUnwindSegueAction(action: Selector, fromViewController: UIViewController, withSender sender: AnyObject?) -> UIViewController? {
        println("action \(action) fromViewController=\(fromViewController)")
        return self.parentViewController
    }

    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }

    public func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let workout = dataStoreNames[indexPath.row]
        //performSegueWithIdentifier("infoSegue", sender: workout)
    }

    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataStoreNames.count
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(tableCell) as! UITableViewCell
        let name = dataStoreNames[indexPath.row]
        cell.textLabel!.text = name
        cell.textLabel!.textColor = UIColor.whiteColor()
        return cell;
    }

}
