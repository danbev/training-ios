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
    var userService: UserService!

    public override func viewDidLoad() {
        super.viewDidLoad()
        let coreDataStack = CoreDataStack.storesFromBundle(["UserWorkouts"], modelName: "FHS")
        workoutService = WorkoutService(coreDataStack: coreDataStack, userService: userService)
    }

    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        var nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.Black
        nav?.tintColor = UIColor.whiteColor()
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    }

    public func setUserService(userService: UserService) {
        self.userService = userService
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
    }

    @IBAction func next(sender: AnyObject) {
        selectedType = workoutTypes[pickerView.selectedRowInComponent(0)]
        switch selectedType {
        case .Reps:
            performSegueWithIdentifier("repsDetailsSegue", sender: self)
        case .Timed:
            performSegueWithIdentifier("durationDetailSegue", sender: self)
        case .Interval:
            performSegueWithIdentifier("intervalDetailsSegue", sender: self)
        case .Prebens:
            performSegueWithIdentifier("prebensDetailsSegue", sender: self)
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
            let controller = segue.destinationViewController as! IntervalInfoViewController
            controller.setWorkoutService(workoutService)
        case .Prebens:
            let controller = segue.destinationViewController as! PrebensInfoViewController
            controller.setWorkoutService(workoutService)
        }
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

