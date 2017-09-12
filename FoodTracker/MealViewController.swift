//
//  MealViewController.swift
//  FoodTracker
//
//  Created by Charlie Zhang on 2017-09-11.
//  Copyright © 2017 Charlie Zhang. All rights reserved.
//

import UIKit
import os.log

class MealViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    //This value is either passed by MealTableViewController in prepare(for:sender:) or constructed as a new meal
    var meal: Meal?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        
        //set up views if editing existing meal
        if let meal = meal {
            navigationItem.title = meal.name
            nameTextField.text = meal.name
            photoImageView.image = meal.photo
            ratingControl.rating = meal.rating
        }
        
        //enable save button only if text field has valid meal name
        updateSaveButtonState()
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        navigationItem.title = textField.text
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //disable save button while editing
        saveButton.isEnabled = false
    }
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //dismiss picker
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //the info dict may contain multiple representations of the image. you want the original
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as?
            UIImage else {
                fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        //set view to selected image
        photoImageView.image = selectedImage
        
        //dismiss picker
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Navigation
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        if(isPresentingInAddMealMode) {
            dismiss(animated: true, completion: nil)
        } else if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        } else {
            fatalError("The MealViewController is not inside a navigation controller")
        }
    }
    
    //This method lets you configure a view controller before it's presented
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        //configure the dest view controller only when save is pressed
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("Cancelling new meal", log: OSLog.default, type: .debug)
            return
        }
        
        let name = nameTextField.text ?? ""
        let photo = photoImageView.image
        let rating = ratingControl.rating
        
        //set the meal to be passed to MealTableViewController
        meal = Meal(name: name, photo: photo, rating: rating)
        
    }

    //MARK: Actions
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        //Hide the keyboard
        nameTextField.resignFirstResponder()
        
        //Let user pick media from photo library
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary //Only allow photos to be picked
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    //MARK: Private methods
    
    private func updateSaveButtonState() {
        //disable save button if text field is empty
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
}

