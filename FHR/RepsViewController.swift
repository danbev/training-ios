//
//  RepsViewController.swift
//  FHR
//
//  Created by Daniel Bevenius on 19/02/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import UIKit
import Foundation

/**
Controlls a Reps based workout

*/
public class RepsViewController: UIViewController {

    typealias FinishDelegate = (RepsViewController) -> ()
    var didFinish: FinishDelegate?
    var workout : RepsWorkout!
    var restTimer: Timer!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var repsLabel: UILabel!
    @IBOutlet weak var descLabel: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var restTimerLabel: UILabel!

    public override func viewDidLoad() {
        super.viewDidLoad()
        taskLabel.text = workout.parent.name()
        repsLabel.text = workout.reps.stringValue
        descLabel.text = workout.parent.desc()
        imageView.image = UIImage(data: workout.parent.image())
        doneButton.hidden = true;
        if restTimer == nil {
            doneButton.hidden = false
        }
    }

    public func restTimer(timer: Timer?) {
        if let t = timer {
            println("restTimer...")
            restTimer = Timer.fromTimer(t, callback: updateTime)
        }
    }

    public func updateTime(timer: Timer) {
        let (min, sec) = timer.elapsedTime()
        if min >= 0 && sec > 0 {
            println("\(min):\(sec)")
            restTimerLabel.text = Timer.timeAsString(min, sec: sec)
        } else {
            restTimerLabel.hidden = true
            doneButton.hidden = false
        }
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func done(sender: AnyObject) {
        self.didFinish!(self)
    }
}
