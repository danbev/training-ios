//
//  RepsInfoViewController.swift
//  FHR
//
//  Created by Daniel Bevenius on 20/06/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation

public class RepsInfoViewController: UIViewController, UITextFieldDelegate {

    private var workoutService: WorkoutService!
    private var workoutType: WorkoutType!
    private var builder: RepsBuilder<RepsWorkout>!
    @IBOutlet weak var repsTextField: UITextField!
    @IBOutlet weak var approxTextField: UITextField!

    public override func viewDidLoad() {
        super.viewDidLoad()
        repsTextField.delegate = self
        approxTextField.delegate = self
    }

    public func setWorkoutService(workoutService: WorkoutService) {
        self.workoutService = workoutService
    }

    @IBAction func next(sender: AnyObject) {
        performSegueWithIdentifier("generalWorkoutDetails", sender: self)
    }

    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let controller = segue.destinationViewController as! AddWorkoutInfoViewController
        controller.setWorkoutService(workoutService)
        //let builder:WorkoutBuilder<Workout> = workoutService.reps(repsTextField.text.toInt()!).approx(approxTextField.text.toInt()!)
        controller.setBuilder(builder)
    }

    public func setWorkoutBuilder(builder: RepsBuilder<RepsWorkout>) {
        self.builder = builder
    }

    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

}
