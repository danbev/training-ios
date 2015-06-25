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

    @IBOutlet weak var pickerView: UIPickerView!
    var workoutTypes = [WorkoutType.Reps, WorkoutType.Timed, WorkoutType.Interval, WorkoutType.Prebens]
    var selectedType: WorkoutType = WorkoutType.Reps
    var workoutService: WorkoutService!

    public override func viewDidLoad() {
        super.viewDidLoad()
    }

    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        var nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.Black
        nav?.tintColor = UIColor.whiteColor()
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
    
    @IBAction func cancel(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
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
        let type = workoutTypes[row]
        debugPrintln("picked \(type.rawValue)")
    }

    public func setWorkoutService(workoutService: WorkoutService) {
        self.workoutService = workoutService
    }

    @IBAction func next(sender: AnyObject) {
        selectedType = workoutTypes[pickerView.selectedRowInComponent(0)]
        switch selectedType {
        case .Reps:
            debugPrintln("next \(selectedType.rawValue)")
            performSegueWithIdentifier("repsDetailsSegue", sender: self)
        case .Timed:
            performSegueWithIdentifier("durationDetailSegue", sender: self)
        case .Interval:
            println(workoutService)
        case .Prebens:
            println(workoutService)
        }
    }

    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch selectedType {
        case .Reps:
            let controller = segue.destinationViewController as! RepsInfoViewController
            controller.setWorkoutService(workoutService)
        case .Timed:
            let controller = segue.destinationViewController as! DurationInfoViewController
            controller.setWorkoutService(workoutService)
        case .Interval:
            println(workoutService)
        case .Prebens:
            println(workoutService)
        }
        println("Prepare for segue:\(segue.identifier)")
    }

    public func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        let pickerLabel = UILabel()
        let titleData = workoutTypes[row].rawValue
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Helvetica", size: 22.0)!,NSForegroundColorAttributeName:UIColor.whiteColor()])
        pickerLabel.attributedText = myTitle
        pickerLabel.textAlignment = NSTextAlignment.Center
        return pickerLabel
    }
}

