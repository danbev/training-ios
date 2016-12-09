//
//  SettingsViewController.swift
//  FHR
//
//  Created by Daniel Bevenius on 22/04/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import UIKit

open class SettingViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    open let weights = "weights"
    open let indoor = "dryGround"
    open let duration = "workoutDuration"
    open let upperbody = WorkoutCategory.UpperBody.rawValue
    open let lowerbody = WorkoutCategory.LowerBody.rawValue
    open let cardio = WorkoutCategory.Cardio.rawValue
    open let warmup = WorkoutCategory.Warmup.rawValue
    open var settings: Settings!

    @IBOutlet weak var wSwitch: UISwitch!
    @IBOutlet weak var dgSwitch: UISwitch!
    @IBOutlet weak var cardioSwitch: UISwitch!
    @IBOutlet weak var lowerBodySwitch: UISwitch!
    @IBOutlet weak var upperBodySwitch: UISwitch!
    @IBOutlet weak var warmupSwitch: UISwitch!
    @IBOutlet weak var timePicker: UIPickerView!

    @IBAction func moreAction(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "moreSettingsSegue", sender: self)
    }

    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "moreSettingsSegue" {
            let controller = segue.destination as! MoreSettingsViewController
            controller.settings(settings)
        }
    }

    @IBAction func backAction(_ sender: UIBarButtonItem) {
    }

    var currentUserWorkout: UserWorkout!
    var userDefaults: UserDefaults!
    let onTintColor = UIColor(red: 0.0/255, green: 200.0/255, blue: 0.0/255, alpha: 1.0)
    var times = [Times.thirty, Times.thirtyFive, Times.fourty, Times.fourtyFive]

    @IBOutlet weak var doneButton: UIButton!

    public enum Times : Int {
        case thirty = 30
        case thirtyFive = 35
        case fourty = 40
        case fourtyFive = 45

        func index() -> Int {
            switch self {
            case .thirty: return 0
            case .thirtyFive: return 1
            case .fourty: return 2
            case .fourtyFive: return 3
            }
        }

        static func fromValue(_ value: Int) -> Times {
            switch value {
            case Times.thirty.rawValue: return Times.thirty
            case Times.thirtyFive.rawValue: return Times.thirtyFive
            case Times.fourty.rawValue: return Times.fourty
            case Times.thirty.rawValue: return Times.fourtyFive
            default: return Times.fourtyFive
            }
        }
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        settings = Settings.settings()
        userDefaults = UserDefaults.standard
        let nav = self.navigationController?.navigationBar
        nav?.tintColor = UIColor.white
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        nav?.backItem?.titleView?.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        /*
        if let font = UIFont(name: "Arial", size: 16) {
            self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
        }
        */
        
        wSwitch.addTarget(self, action: #selector(SettingViewController.weightChanged(_:)), for: UIControlEvents.valueChanged)
        wSwitch.onTintColor = onTintColor

        dgSwitch.addTarget(self, action: #selector(SettingViewController.dryGroundChanged(_:)), for: UIControlEvents.valueChanged)
        dgSwitch.onTintColor = onTintColor
        upperBodySwitch.addTarget(self, action: #selector(SettingViewController.upperBodyChanged(_:)), for: UIControlEvents.valueChanged)
        upperBodySwitch.onTintColor = onTintColor
        lowerBodySwitch.addTarget(self, action: #selector(SettingViewController.lowerBodyChanged(_:)), for: UIControlEvents.valueChanged)
        lowerBodySwitch.onTintColor = onTintColor
        cardioSwitch.addTarget(self, action: #selector(SettingViewController.cardioChanged(_:)), for: UIControlEvents.valueChanged)
        cardioSwitch.onTintColor = onTintColor
        warmupSwitch.addTarget(self, action: #selector(SettingViewController.warmupChanged(_:)), for: UIControlEvents.valueChanged)
        warmupSwitch.onTintColor = onTintColor

        wSwitch.setOn(booleanValue(weights, defaultValue: true), animated: false)
        dgSwitch.setOn(booleanValue(indoor, defaultValue: true), animated: false)
        upperBodySwitch.setOn(booleanValue(upperbody, defaultValue: true), animated: false)
        lowerBodySwitch.setOn(booleanValue(lowerbody, defaultValue: true), animated: false)
        cardioSwitch.setOn(booleanValue(cardio, defaultValue: true), animated: false)
        warmupSwitch.setOn(booleanValue(warmup, defaultValue: true), animated: false)
        timePicker.selectRow(index(duration, defaultValue: Times.fourtyFive), inComponent: 0, animated: false)
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    func booleanValue(_ keyName: String, defaultValue: Bool) -> Bool {
        if let value = userDefaults!.object(forKey: keyName) as? Bool {
            return value
        }
        return defaultValue;
    }

    func index(_ keyName: String, defaultValue: Times) -> Int {
        if let value = userDefaults!.object(forKey: keyName) as? Int {
            return Times.fromValue(value).index()
        }
        return defaultValue.index();
    }

    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return times.count
    }

    open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return times[row].rawValue.description
    }

    open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        userDefaults!.set(times[row].rawValue, forKey: duration)
        userDefaults.synchronize()
    }

    open func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: times[row].rawValue.description, attributes: [NSFontAttributeName:UIFont(name: "Helvetica", size: 10.0)!, NSForegroundColorAttributeName : UIColor.white])
        return attributedString
    }

    open func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        let titleData = times[row].rawValue.description
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Helvetica", size: 22.0)!,NSForegroundColorAttributeName:UIColor.white])
        pickerLabel.attributedText = myTitle
        return pickerLabel
    }

    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func weightChanged(_ sw: UISwitch) {
        saveValue(sw.isOn, keyName: weights)
    }

    func dryGroundChanged(_ sw: UISwitch) {
        saveValue(sw.isOn, keyName: indoor)
    }

    func lowerBodyChanged(_ sw: UISwitch) {
        saveValue(sw.isOn, keyName: lowerbody)
    }

    func upperBodyChanged(_ sw: UISwitch) {
        saveValue(sw.isOn, keyName: upperbody)
    }

    func cardioChanged(_ sw: UISwitch) {
        saveValue(sw.isOn, keyName: cardio)
    }

    func warmupChanged(_ sw: UISwitch) {
        saveValue(sw.isOn, keyName: warmup)
    }

    func saveValue(_ value: Bool, keyName: String) {
        userDefaults!.set(value, forKey: keyName)
        userDefaults.synchronize()
    }

    @IBAction func unwindToMainMenu(_ sender: UIStoryboardSegue) {
        _ = sender.source as! MoreSettingsViewController
    }

}
