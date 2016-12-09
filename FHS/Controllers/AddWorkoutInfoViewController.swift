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

open class AddWorkoutInfoViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var workoutName: UITextField!
    @IBOutlet weak var workoutDescription: UITextView!
    @IBOutlet weak var noVideoLabel: UILabel!
    fileprivate var videoUrl: String?
    fileprivate var workoutType: WorkoutType!
    fileprivate var workoutBuilder: WorkoutBuilder!

    open func setWorkoutType(_ workoutType: WorkoutType) {
        self.workoutType = workoutType
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        workoutDescription.delegate = self
        workoutName.delegate = self
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.black
        nav?.tintColor = UIColor.white
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }

    open func setBuilder(_ workoutBuilder: WorkoutBuilder) {
        self.workoutBuilder = workoutBuilder
    }

    @IBAction func next(_ sender: AnyObject) {
        performSegue(withIdentifier: "generalWorkoutDetails2", sender: self)
    }


    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let _ = workoutBuilder.name(workoutName.text!)
            .workoutName(workoutName.text!)
            .description(workoutDescription.text)
            .videoUrl(videoUrl)
        let controller = segue.destination as! GeneralDetails2
        controller.setBuilder(workoutBuilder)
    }

    open func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            self.view.endEditing(true)
            return false
        }
        return true
    }

    @IBAction func videoButtonAction(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.mediaTypes = [kUTTypeMovie as String]

            let frontCamera = UIImagePickerControllerCameraDevice.front
            picker.cameraDevice = UIImagePickerController.isCameraDeviceAvailable(frontCamera) ? frontCamera: UIImagePickerControllerCameraDevice.rear
            self.present(picker, animated: true, completion: nil)
        }
    }

    @IBAction func selectVideo(_ sender: AnyObject) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
        picker.mediaTypes = [kUTTypeMovie as String]
        self.present(picker, animated: true, completion: nil)
    }

    @IBAction func cancel(_ sender: AnyObject) {
        debugPrint("cancel add workout")
        let _ = navigationController?.popToRootViewController(animated: true)
    }

    open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let tempImage = info[UIImagePickerControllerMediaURL] as! URL!
        videoUrl = tempImage?.relativePath
        if let _ = videoUrl {
            debugPrint("Saving video : :\(videoUrl)")
            noVideoLabel.isHidden = true
            UISaveVideoAtPathToSavedPhotosAlbum(videoUrl!, nil, nil, nil)
        }
        picker.dismiss(animated: true, completion: nil)
    }

    open func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        noVideoLabel.isHidden = false
        picker.dismiss(animated: true, completion: nil)
    }

    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.view.endEditing(true)
        return true
    }
}
