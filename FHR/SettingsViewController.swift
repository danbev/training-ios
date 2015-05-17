//
//  SettingsViewController.swift
//  FHR
//
//  Created by Daniel Bevenius on 22/04/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import UIKit

public class SettingViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    public let weights = "weights"
    public let indoor = "dryGround"
    public let duration = "workoutDuration"
    public let upperbody = WorkoutCategory.UpperBody.rawValue
    public let lowerbody = WorkoutCategory.LowerBody.rawValue
    public let cardio = WorkoutCategory.Cardio.rawValue
    public let warmup = WorkoutCategory.Warmup.rawValue

    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var wSwitch: UISwitch!
    @IBOutlet weak var dgSwitch: UISwitch!
    @IBOutlet weak var cardioSwitch: UISwitch!
    @IBOutlet weak var lowerBodySwitch: UISwitch!
    @IBOutlet weak var upperBodySwitch: UISwitch!
    @IBOutlet weak var warmupSwitch: UISwitch!
    @IBOutlet weak var timePicker: UIPickerView!

    var currentUserWorkout: UserWorkout!
    var userDefaults: NSUserDefaults!
    let onTintColor = UIColor.greenColor()
    var times = [Times.Thirty, Times.ThirtyFive, Times.Fourty, Times.FourtyFive]

    @IBOutlet weak var doneButton: UIButton!

    public enum Times : Int {
        case Thirty = 30
        case ThirtyFive = 35
        case Fourty = 40
        case FourtyFive = 45

        func index() -> Int {
            switch self {
            case .Thirty: return 0
            case .ThirtyFive: return 1
            case .Fourty: return 2
            case .FourtyFive: return 3
            }
        }

        static func fromValue(value: Int) -> Times {
            switch value {
            case Times.Thirty.rawValue: return Times.Thirty
            case Times.ThirtyFive.rawValue: return Times.ThirtyFive
            case Times.Fourty.rawValue: return Times.Fourty
            case Times.Thirty.rawValue: return Times.FourtyFive
            default: return Times.FourtyFive
            }
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        userDefaults = NSUserDefaults.standardUserDefaults()
        var nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.Black
        nav?.tintColor = UIColor.whiteColor()
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]

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
        warmupSwitch.addTarget(self, action: Selector("warmupChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        warmupSwitch.onTintColor = onTintColor

        wSwitch.setOn(booleanValue(weights, defaultValue: true), animated: false)
        dgSwitch.setOn(booleanValue(indoor, defaultValue: true), animated: false)
        upperBodySwitch.setOn(booleanValue(upperbody, defaultValue: true), animated: false)
        lowerBodySwitch.setOn(booleanValue(lowerbody, defaultValue: true), animated: false)
        cardioSwitch.setOn(booleanValue(cardio, defaultValue: true), animated: false)
        warmupSwitch.setOn(booleanValue(warmup, defaultValue: true), animated: false)
        timePicker.selectRow(index(duration, defaultValue: Times.FourtyFive), inComponent: 0, animated: false)

        self.backButton = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
    }

    func booleanValue(keyName: String, defaultValue: Bool) -> Bool {
        if let value = userDefaults!.objectForKey(keyName) as? Bool {
            return value
        }
        return defaultValue;
    }

    func index(keyName: String, defaultValue: Times) -> Int {
        if let value = userDefaults!.objectForKey(keyName) as? Int {
            return Times.fromValue(value).index()
        }
        return defaultValue.index();
    }

    public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return times.count
    }

    public func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return times[row].rawValue.description
    }

    public func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        userDefaults!.setInteger(times[row].rawValue, forKey: duration)
        userDefaults.synchronize()
    }

    public func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: times[row].rawValue.description, attributes: [NSFontAttributeName:UIFont(name: "Helvetica", size: 10.0)!, NSForegroundColorAttributeName : UIColor.whiteColor()])
        return attributedString
    }

    public func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        let pickerLabel = UILabel()
        let titleData = times[row].rawValue.description
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Helvetica", size: 22.0)!,NSForegroundColorAttributeName:UIColor.whiteColor()])
        pickerLabel.attributedText = myTitle
        return pickerLabel
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

    func warmupChanged(sw: UISwitch) {
        saveValue(sw.on, keyName: warmup)
    }

    func saveValue(value: Bool, keyName: String) {
        userDefaults!.setBool(value, forKey: keyName)
        userDefaults.synchronize()
    }

}
