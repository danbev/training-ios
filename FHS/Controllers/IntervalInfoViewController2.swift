//
//  IntervalInfoViewController2.swift
//  FHR
//
//  Created by Daniel Bevenius on 20/06/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation

public class IntervalInfoViewController2: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    private var workoutService: WorkoutService!
    private var builder: IntervalBuilder!
    @IBOutlet weak var durationLabel: UILabel!

    @IBOutlet weak var restPicker: UIPickerView!
    @IBOutlet weak var restDurationLabel: UILabel!
    private var restWorkouts: [String]!


    public override func viewDidLoad() {
        super.viewDidLoad()
        restPicker.selectRow(restWorkouts.count/2, inComponent: 0, animated: false)
    }

    public func setBuilder(builder: IntervalBuilder) {
        self.builder = builder
        let workoutName = builder.workoutName()
        restWorkouts = restWorkouts.filter { $0 != workoutName }
    }

    public func setWorkoutService(workoutService: WorkoutService) {
        self.workoutService = workoutService
        restWorkouts = workoutService.fetchDurationWorkoutsDestinct()
    }

    @IBAction func next(sender: AnyObject) {
        performSegueWithIdentifier("intervalDetails3Segue", sender: self)
    }

    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let controller = segue.destinationViewController as! IntervalInfoViewController3
        let restWorkoutName = restWorkouts[restPicker.selectedRowInComponent(0)]
        let rest = workoutService.fetchWorkout(restWorkoutName) as! DurationWorkoutManagedObject
        builder.rest(rest, duration: restDurationLabel.text!.toInt()!)
        controller.setBuilder(builder)
    }

    public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return restWorkouts.count
    }

    public func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return restWorkouts[row]
    }

    public func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    }

    public func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let workoutName = restWorkouts[row]
        let attributedString = NSAttributedString(string: workoutName, attributes: [NSFontAttributeName:UIFont(name: "Helvetica", size: 10.0)!, NSForegroundColorAttributeName : UIColor.whiteColor()])
        return attributedString
    }

    public func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        let titleData = restWorkouts[row]
        let pickerLabel = UILabel()
        pickerLabel.textAlignment = NSTextAlignment.Center
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Helvetica", size: 22.0)!,NSForegroundColorAttributeName:UIColor.whiteColor()])
        pickerLabel.attributedText = myTitle
        return pickerLabel
    }

    @IBAction func cancel(sender: AnyObject) {
        navigationController?.popToRootViewControllerAnimated(true)
    }

    @IBAction func restDurationStepper(sender: UIStepper) {
        restDurationLabel.text = Int(sender.value).description
    }
    
}
