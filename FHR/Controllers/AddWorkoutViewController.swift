//
//  AddWorkoutViewController.swift
//  FHR
//
//  Created by Daniel Bevenius on 19/06/15.
//  Copyright (c) 2014 Daniel Bevenius. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

/**
* Main view controller for workout tasks.
*/
public class AddWorkoutViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    var workoutTypes = [WorkoutType.Reps, WorkoutType.Timed, WorkoutType.Interval, WorkoutType.Prebens]

    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: {})
    }

    public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return workoutTypes.count
    }

    public func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return workoutTypes[row].rawValue
    }

    public func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        debugPrintln("picked \(workoutTypes[row].rawValue)")
    }

    /*
    public func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: workoutTypes[row].rawValue, attributes: [NSFontAttributeName:UIFont(name: "Helvetica", size: 10.0)!, NSForegroundColorAttributeName : UIColor.whiteColor()])
        return attributedString
    }
    */

    public func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        let pickerLabel = UILabel()
        let titleData = workoutTypes[row].rawValue
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Helvetica", size: 22.0)!,NSForegroundColorAttributeName:UIColor.whiteColor()])
        pickerLabel.attributedText = myTitle
        pickerLabel.textAlignment = NSTextAlignment.Center
        return pickerLabel
    }
}

