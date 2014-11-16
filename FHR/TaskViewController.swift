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

    var workoutTask : WorkoutTask!
    @IBOutlet weak var taskLabel: UILabel!

    public override func viewDidLoad() {
        super.viewDidLoad()
        taskLabel.text = workoutTask.name
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
