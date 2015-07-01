//
//  IntervalInfoViewController.swift
//  FHR
//
//  Created by Daniel Bevenius on 20/06/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation

public class IntervalInfoViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    private var workoutService: WorkoutService!
    private var workoutType: WorkoutType!
    private var builder: DurationBuilder!
    @IBOutlet weak var durationLabel: UILabel!

    @IBOutlet weak var workoutPicker: UIPickerView!
    @IBOutlet weak var restPicker: UIPickerView!
    @IBOutlet weak var intervalsLabel: UILabel!
    @IBOutlet weak var workDurationLabel: UILabel!
    @IBOutlet weak var restDurationLabel: UILabel!
    private var workouts: [DurationWorkout]!
    private var restWorkouts: [DurationWorkout]!


    public override func viewDidLoad() {
        super.viewDidLoad()
        workouts = workoutService.fetchDurationWorkouts()
        restWorkouts = workoutService.fetchDurationWorkouts()
    }

    public func setWorkoutService(workoutService: WorkoutService) {
        self.workoutService = workoutService
    }

    @IBAction func next(sender: AnyObject) {
        performSegueWithIdentifier("generalWorkoutDetails", sender: self)
    }

    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let controller = segue.destinationViewController as! AddWorkoutInfoViewController
        let workout = workouts[workoutPicker.selectedRowInComponent(0)]
        let rest = restWorkouts[restPicker.selectedRowInComponent(0)]
        let builder = workoutService.interval(workout, duration: workDurationLabel.text!.toInt()!)
            .rest(rest, duration: restDurationLabel.text!.toInt()!)
            .intervals(intervalsLabel.text!.toInt()!)
        controller.setBuilder(builder)
    }


    public func setWorkoutBuilder(builder: DurationBuilder) {
        self.builder = builder
    }

    @IBAction func stepper(sender: UIStepper) {
        intervalsLabel.text = Int(sender.value).description
    }

    public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView == workoutPicker ? workouts.count : restWorkouts.count
    }

    public func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerView == workoutPicker ? workouts[row].workoutName : restWorkouts[row].workoutName
    }

    public func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    }

    public func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let workoutName = pickerView == workoutPicker ? workouts[row].workoutName : restWorkouts[row].workoutName
        let attributedString = NSAttributedString(string: workoutName, attributes: [NSFontAttributeName:UIFont(name: "Helvetica", size: 10.0)!, NSForegroundColorAttributeName : UIColor.whiteColor()])
        return attributedString
    }

    public func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        let titleData = pickerView == workoutPicker ? workouts[row].workoutName : restWorkouts[row].workoutName
        let pickerLabel = UILabel()
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Helvetica", size: 22.0)!,NSForegroundColorAttributeName:UIColor.whiteColor()])
        pickerLabel.attributedText = myTitle
        return pickerLabel
    }

    @IBAction func cancel(sender: AnyObject) {
        navigationController?.popToRootViewControllerAnimated(true)
    }

    @IBAction func workDurationStepper(sender: UIStepper) {
        workDurationLabel.text = Int(sender.value).description
    }

    @IBAction func restDurationStepper(sender: UIStepper) {
        restDurationLabel.text = Int(sender.value).description
    }

}
