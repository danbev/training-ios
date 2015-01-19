//
//  TaskViewController.swift
//  FHR
//
//  Created by Daniel Bevenius on 20/09/14.
//  Copyright (c) 2014 Daniel Bevenius. All rights reserved.
//

import UIKit
import Foundation

/**
Controls the Workout task details view.

*/
public class TaskViewController: UIViewController {

    var workoutTask : RepsWorkout!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var repsLabel: UILabel!
    @IBOutlet weak var descLabel: UITextView!

    public override func viewDidLoad() {
        super.viewDidLoad()
        let workout = workoutTask.parent as Workout
        taskLabel.text = workout.name
        repsLabel.text = workoutTask.reps.stringValue
        descLabel.text = workout.desc
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
