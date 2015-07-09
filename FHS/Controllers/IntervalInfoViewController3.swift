//
//  IntervalInfoViewController3.swift
//  FHR
//
//  Created by Daniel Bevenius on 20/06/15.
//  Copyright (c) 2015 Daniel Bevenius. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation

public class IntervalInfoViewController3: UIViewController {

    private var builder: IntervalBuilder!

    @IBOutlet weak var intervalsLabel: UILabel!

    public override func viewDidLoad() {
        super.viewDidLoad()
    }

    public func setBuilder(builder: IntervalBuilder) {
        self.builder = builder
    }

    @IBAction func next(sender: AnyObject) {
        performSegueWithIdentifier("generalWorkoutDetails", sender: self)
    }

    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let controller = segue.destinationViewController as! AddWorkoutInfoViewController
        builder.intervals(intervalsLabel.text!.toInt()!)
        controller.setBuilder(builder)
    }

    @IBAction func stepper(sender: UIStepper) {
        intervalsLabel.text = Int(sender.value).description
    }

    public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    @IBAction func cancel(sender: AnyObject) {
        navigationController?.popToRootViewControllerAnimated(true)
    }

    @IBAction func back(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }

}
