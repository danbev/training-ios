//
//  AddWorkoutInfoViewController.swift
//  FHR
//
//  Created by Daniel Bevenius on 20/06/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
import MediaPlayer
import MobileCoreServices

public class GeneralDetails2: UIViewController {

    private var workoutBuilder: WorkoutBuilder!

    @IBOutlet weak var weightsSwitch: UISwitch!
    @IBOutlet weak var dryGroundSwitch: UISwitch!
    @IBOutlet weak var warmupSwitch: UISwitch!
    @IBOutlet weak var upperbodySwitch: UISwitch!
    @IBOutlet weak var lowerbodySwitch: UISwitch!
    @IBOutlet weak var cardioSwitch: UISwitch!
    @IBOutlet weak var postRestLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    private var categories = Set<WorkoutCategory>()
    private let onTintColor = UIColor(red: 0.0/255, green: 200.0/255, blue: 0.0/255, alpha: 1.0)

    public override func viewDidLoad() {
        super.viewDidLoad()
        var nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.Black
        nav?.tintColor = UIColor.whiteColor()
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        weightsSwitch.setOn(false, animated: false)
        weightsSwitch.onTintColor = onTintColor
        dryGroundSwitch.setOn(false, animated: false)
        dryGroundSwitch.onTintColor = onTintColor
        warmupSwitch.setOn(false, animated: false)
        warmupSwitch.onTintColor = onTintColor
        upperbodySwitch.setOn(false, animated: false)
        upperbodySwitch.onTintColor = onTintColor
        lowerbodySwitch.setOn(false, animated: false)
        lowerbodySwitch.onTintColor = onTintColor
        cardioSwitch.setOn(false, animated: false)
        cardioSwitch.onTintColor = onTintColor
        stepper.value = 1

    }

    func gatherCategories() -> [WorkoutCategory] {
        var categories = [WorkoutCategory]()
        if warmupSwitch.on {
            categories.append(WorkoutCategory.Warmup)
        }
        if upperbodySwitch.on {
            categories.append(WorkoutCategory.UpperBody)
        }
        if lowerbodySwitch.on {
            categories.append(WorkoutCategory.LowerBody)
        }
        if cardioSwitch.on {
            categories.append(WorkoutCategory.Cardio)
        }
        return categories
    }

    public func setBuilder(workoutBuilder: WorkoutBuilder) {
        self.workoutBuilder = workoutBuilder
    }

    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "unwindToMain" {
            let workout = workoutBuilder.language("en")
                .weights(weightsSwitch.on)
                .dryGround(dryGroundSwitch.on)
                .postRestTime(postRestLabel.text!.toInt()!)
                .categories(gatherCategories())
                .saveWorkout()
            debugPrintln("saved workout \(workout)")
            Settings.enableUserWorkoutsStore()
        }
    }

    @IBAction func save(sender: AnyObject) {
        /*
        let workout = workoutBuilder.language("en")
            .weights(weightsSwitch.on)
            .dryGround(dryGroundSwitch.on)
            .postRestTime(postRestLabel.text!.toInt()!)
            .categories(gatherCategories())
            .saveWorkout()
        debugPrintln("saved workout \(workout)")
        Settings.enableUserWorkoutsStore()
        navigationController?.popToRootViewControllerAnimated(true)
        */
    }

    @IBAction func cancel(sender: AnyObject) {
        navigationController?.popToRootViewControllerAnimated(true)
    }

    @IBAction func stepper(sender: UIStepper) {
        postRestLabel.text = Int(sender.value).description
    }
}
