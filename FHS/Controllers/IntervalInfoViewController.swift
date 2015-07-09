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

    @IBOutlet weak var workoutPicker: UIPickerView!
    @IBOutlet weak var workDurationLabel: UILabel!
    private var workouts: [String]!

    public override func viewDidLoad() {
        super.viewDidLoad()
        workoutPicker.selectRow(workouts.count/2, inComponent: 0, animated: false)
    }

    public func setWorkoutService(workoutService: WorkoutService) {
        self.workoutService = workoutService
        workouts = workoutService.fetchDurationWorkoutsDestinct()
    }

    @IBAction func next(sender: AnyObject) {
        performSegueWithIdentifier("intervalDetails2Segue", sender: self)
    }

    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let controller = segue.destinationViewController as! IntervalInfoViewController2
        controller.setWorkoutService(workoutService)
        let workoutName = workouts[workoutPicker.selectedRowInComponent(0)]
        let workout = workoutService.fetchWorkout(workoutName) as! DurationWorkout
        let builder = workoutService.interval(workout, duration: workDurationLabel.text!.toInt()!)
        controller.setBuilder(builder)
    }

    public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return workouts.count
    }

    public func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return workouts[row]
    }

    public func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    }

    public func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        let titleData = workouts[row]
        let pickerLabel = UILabel()
        pickerLabel.textAlignment = NSTextAlignment.Center
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

}
