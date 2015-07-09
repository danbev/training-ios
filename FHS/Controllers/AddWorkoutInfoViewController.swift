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

public class AddWorkoutInfoViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var workoutName: UITextField!
    @IBOutlet weak var workoutDescription: UITextView!
    @IBOutlet weak var noVideoLabel: UILabel!
    private var videoUrl: String?
    private var workoutType: WorkoutType!
    private var workoutBuilder: WorkoutBuilder!

    public func setWorkoutType(workoutType: WorkoutType) {
        self.workoutType = workoutType
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        workoutDescription.delegate = self
        workoutName.delegate = self
        var nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.Black
        nav?.tintColor = UIColor.whiteColor()
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    }

    public func setBuilder(workoutBuilder: WorkoutBuilder) {
        self.workoutBuilder = workoutBuilder
    }

    @IBAction func next(sender: AnyObject) {
        performSegueWithIdentifier("generalWorkoutDetails2", sender: self)
    }


    public override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        workoutBuilder.name(workoutName.text)
            .workoutName(workoutName.text)
            .description(workoutDescription.text)
            .videoUrl(videoUrl)
        let controller = segue.destinationViewController as! GeneralDetails2
        controller.setBuilder(workoutBuilder)
    }

    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            self.view.endEditing(true)
            return false
        }
        return true
    }

    @IBAction func videoButtonAction(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            var picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.mediaTypes = [kUTTypeMovie]

            let frontCamera = UIImagePickerControllerCameraDevice.Front
            picker.cameraDevice = UIImagePickerController.isCameraDeviceAvailable(frontCamera) ? frontCamera: UIImagePickerControllerCameraDevice.Rear
            self.presentViewController(picker, animated: true, completion: nil)
        }
    }

    @IBAction func selectVideo(sender: AnyObject) {
        var picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
        picker.mediaTypes = [kUTTypeMovie]
        self.presentViewController(picker, animated: true, completion: nil)
    }

    @IBAction func cancel(sender: AnyObject) {
        debugPrintln("cancel add workout")
        navigationController?.popToRootViewControllerAnimated(true)
    }

    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let tempImage = info[UIImagePickerControllerMediaURL] as! NSURL!
        videoUrl = tempImage.relativePath
        if let url = videoUrl {
            debugPrintln("Saving video : :\(videoUrl)")
            noVideoLabel.hidden = true
            UISaveVideoAtPathToSavedPhotosAlbum(videoUrl, nil, nil, nil)
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

    public func imagePickerControllerDidCancel(picker: UIImagePickerController){
        noVideoLabel.hidden = false
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.view.endEditing(true)
        return true
    }
}
