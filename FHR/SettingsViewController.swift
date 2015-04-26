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


    public override func viewDidLoad() {
        super.viewDidLoad()
        userDefaults = NSUserDefaults.standardUserDefaults()

        wSwitch.addTarget(self, action: Selector("weightChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        dgSwitch.addTarget(self, action: Selector("dryGroundChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        upperBodySwitch.addTarget(self, action: Selector("upperBodyChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        lowerBodySwitch.addTarget(self, action: Selector("lowerBodyChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        cardioSwitch.addTarget(self, action: Selector("cardioChanged:"), forControlEvents: UIControlEvents.ValueChanged)

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
        if sw.on {
            println("weight on")
        } else {
            println("weight off")
        }
    }

    func dryGroundChanged(sw: UISwitch) {
        saveValue(sw.on, keyName: indoor)
        if sw.on {
            println("dry ground on")
        } else {
            println("dry ground off")
        }
    }

    func lowerBodyChanged(sw: UISwitch) {
        saveValue(sw.on, keyName: lowerbody)
        if sw.on {
            println("lowerBody on")
        } else {
            println("lowerBody off")
        }
    }

    func upperBodyChanged(sw: UISwitch) {
        saveValue(sw.on, keyName: upperbody)
        if sw.on {
            println("upperBody on")
        } else {
            println("upperBody off")
        }
    }

    func cardioChanged(sw: UISwitch) {
        saveValue(sw.on, keyName: cardio)
        if sw.on {
            println("cardio on")
        } else {
            println("cardio off")
        }
    }

    func saveValue(value: Bool, keyName: String) {
        println("Saving \(value) for key \(keyName)")
        userDefaults!.setBool(value, forKey: keyName)
        userDefaults.synchronize()
    }

    @IBAction func doneButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
