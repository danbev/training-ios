//
//  SettingsViewController.swift
//  FHR
//
//  Created by Daniel Bevenius on 22/04/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import UIKit

public class SettingViewController: UIViewController {

    public let weights = "weights"
    public let indoor = "indoor"
    public let upperbody = WorkoutCategory.UpperBody.rawValue
    public let lowerbody = WorkoutCategory.LowerBody.rawValue
    public let cardio = WorkoutCategory.Cardio.rawValue

    @IBOutlet weak var wSwitch: UISwitch!
    @IBOutlet weak var dgSwitch: UISwitch!
    @IBOutlet weak var cardioSwitch: UISwitch!
    @IBOutlet weak var lowerBodySwitch: UISwitch!
    @IBOutlet weak var upperBodySwitch: UISwitch!

    var currentUserWorkout: UserWorkout!
    var userDefaults: NSUserDefaults!
    let onTintColor = UIColor.grayColor()


    public override func viewDidLoad() {
        super.viewDidLoad()
        userDefaults = NSUserDefaults.standardUserDefaults()

        wSwitch.addTarget(self, action: Selector("weightChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        wSwitch.onTintColor = onTintColor

        dgSwitch.addTarget(self, action: Selector("dryGroundChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        dgSwitch.onTintColor = onTintColor
        upperBodySwitch.addTarget(self, action: Selector("upperBodyChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        upperBodySwitch.onTintColor = onTintColor
        lowerBodySwitch.addTarget(self, action: Selector("lowerBodyChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        lowerBodySwitch.onTintColor = onTintColor
        cardioSwitch.addTarget(self, action: Selector("cardioChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        cardioSwitch.onTintColor = onTintColor

        wSwitch.setOn(booleanValue(weights, defaultValue: true), animated: false)
        dgSwitch.setOn(booleanValue(indoor, defaultValue: true), animated: false)
        upperBodySwitch.setOn(booleanValue(upperbody, defaultValue: true), animated: false)
        lowerBodySwitch.setOn(booleanValue(lowerbody, defaultValue: true), animated: false)
        cardioSwitch.setOn(booleanValue(cardio, defaultValue: true), animated: false)
    }

    func booleanValue(keyName: String, defaultValue: Bool) -> Bool {
        if let value = userDefaults!.objectForKey(keyName) {
            return value as! Bool
        }
        return defaultValue;
    }


    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func weightChanged(sw: UISwitch) {
        saveValue(sw.on, keyName: weights)
    }

    func dryGroundChanged(sw: UISwitch) {
        saveValue(sw.on, keyName: indoor)
    }

    func lowerBodyChanged(sw: UISwitch) {
        saveValue(sw.on, keyName: lowerbody)
    }

    func upperBodyChanged(sw: UISwitch) {
        saveValue(sw.on, keyName: upperbody)
    }

    func cardioChanged(sw: UISwitch) {
        saveValue(sw.on, keyName: cardio)
    }

    func saveValue(value: Bool, keyName: String) {
        userDefaults!.setBool(value, forKey: keyName)
        userDefaults.synchronize()
    }

    @IBAction func doneButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
