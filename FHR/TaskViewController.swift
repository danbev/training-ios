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

    var workout : WorkoutProtocol!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var repsLabel: UILabel!
    @IBOutlet weak var descLabel: UITextView!
    @IBOutlet weak var imageView: UIImageView!

    public override func viewDidLoad() {
        super.viewDidLoad()
        taskLabel.text = workout.name()
        repsLabel.text = "??"
        descLabel.text = workout.desc()
        imageView.image = UIImage(data: workout.image())
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
