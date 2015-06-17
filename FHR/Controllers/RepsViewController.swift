//
//  RepsViewController.swift
//  FHR
//
//  Created by Daniel Bevenius on 19/02/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import UIKit
import Foundation
import AVKit
import AVFoundation

/**
Controlls a Reps based workout

*/
public class RepsViewController: BaseWorkoutController, UITableViewDelegate, UITableViewDataSource {

    let tableCell = "timeCell"
    var repsWorkout: RepsWorkout!
    @IBOutlet weak var repsLabel: UILabel!
    @IBOutlet weak var totalTime: UILabel!
    @IBOutlet weak var tableView: UITableView!

    public override func viewDidLoad() {
        super.viewDidLoad()
        repsLabel.text = repsWorkout.repititions.stringValue
    }

    public override func initWith(workout: Workout, restTimer: CountDownTimer?, finishDelegate: FinishDelegate) {
        super.initWith(workout, restTimer: restTimer, finishDelegate: finishDelegate)
        repsWorkout = workout as! RepsWorkout
    }

    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }

    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(tableCell) as! UITableViewCell
        if indexPath.row == 0 {
            cell.textLabel!.text = "Rest time"
            cell.textLabel!.textAlignment = NSTextAlignment.Center
            cell.textLabel!.textColor = UIColor.whiteColor()
        } else {
            cell.textLabel!.text = "00:00"
            cell.textLabel!.textAlignment = NSTextAlignment.Center
            cell.textLabel!.textColor = UIColor.whiteColor()
        }
        return cell;
    }

}
