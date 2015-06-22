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

    private lazy var coreDataStack = CoreDataStack()
    private var workoutService: WorkoutService!
    private var workoutType: WorkoutType!
    private var builder: RepsBuilder<RepsWorkout>!
    @IBOutlet weak var repsTextField: UITextField!
    @IBOutlet weak var approxTextField: UITextField!

    public override func viewDidLoad() {
        super.viewDidLoad()
        repsTextField.delegate = self
        approxTextField.delegate = self
        workoutService = WorkoutService(context: coreDataStack.context)
    }

    public func setWorkoutBuilder(builder: RepsBuilder<RepsWorkout>) {
        self.builder = builder
    }

    @IBAction func save(sender: AnyObject) {
        builder.reps(repsTextField.text.toInt()!).approx(approxTextField.text.toInt()!)
        let workout = workoutService.saveWorkout(builder)
        println("saved \(workout)")
        navigationController?.popToRootViewControllerAnimated(true)
    }

    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    @IBAction func cancel(sender: AnyObject) {
        debugPrintln("cancel add workout")
        navigationController?.popToRootViewControllerAnimated(true)
    }

}
