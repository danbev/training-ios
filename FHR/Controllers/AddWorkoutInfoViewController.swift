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

public class AddWorkoutInfoViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var workoutName: UITextField!
    @IBOutlet weak var workoutDescription: UITextView!

    public override func viewDidLoad() {
        super.viewDidLoad()
        workoutDescription.delegate = self
    }

    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    @IBAction func videoButtonAction(sender: AnyObject) {
        debugPrintln("take a video")
    }

    @IBAction func save(sender: AnyObject) {
        debugPrintln("save new workout")
    }

    @IBAction func cancel(sender: AnyObject) {
        debugPrintln("cancel add workout")
    }
}
