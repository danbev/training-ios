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

public class DurationInfoViewController: UIViewController, UITextFieldDelegate {

    private var workoutService: WorkoutService!
    private var workoutType: WorkoutType!
    private var builder: DurationBuilder!
    @IBOutlet weak var durationTextField: UITextField!

    public override func viewDidLoad() {
        super.viewDidLoad()
        durationTextField.delegate = self
    }

    public func setWorkoutService(workoutService: WorkoutService) {
        self.workoutService = workoutService
    }

    @IBAction func next(sender: AnyObject) {
        performSegueWithIdentifier("generalWorkoutDetails", sender: self)
    }

    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let controller = segue.destinationViewController as! AddWorkoutInfoViewController
        controller.setBuilder(workoutService.duration(durationTextField.text.toInt()!))
    }

    public func setWorkoutBuilder(builder: DurationBuilder) {
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
