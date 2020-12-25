//
//  ViewController.swift
//  MemeMe
//
//  Created by Paul Smith on 12/22/20.
//

import UIKit

struct Meme {
    var topText: String!
    var bottomText: String!
    var originalImage: UIImage!
    var memedImage: UIImage!
}

class ViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate  {
    
    let topText: String = "TOP"
    let bottomText: String = "BOTTOM"

    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topTextField.textAlignment = .center
        bottomTextField.textAlignment = .center
        
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        let memeTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedString.Key.strokeWidth:  -5.0
        ]
        
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        
        imageView.contentMode = .scaleAspectFit
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setToDefaultState()
        subscribeToKeyboardNotifications()
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomTextField.isEditing {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }

    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func setToDefaultState() {
        topTextField.text = topText
        bottomTextField.text = bottomText
        imageView.image = UIImage(systemName: "photo.fill")
        shareButton.isEnabled = false
    }
    
    func saveMemedImage(_ memedImage: UIImage) {
            // Create the meme
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memedImage: memedImage)
        
        //let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //appDelegate.memes.append(meme)
    }
    
    func generateMemedImage() -> UIImage {
        
        navigationController?.setToolbarHidden(true, animated: false)
        navigationController?.setNavigationBarHidden(true, animated: false)

        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        navigationController?.setToolbarHidden(false, animated: false)
        navigationController?.setNavigationBarHidden(false, animated: false)

        return memedImage
    }

    @IBAction func pickImageFromAlbum(_ sender: Any) {
        pickAnImage(sourceType: .photoLibrary)
    }
    
    @IBAction func pickImageFromCamera(_ sender: Any) {
        pickAnImage(sourceType: .camera)
    }
    
    @IBAction func cancelImage(_ sender: Any) {
        setToDefaultState()
    }
    
    @IBAction func shareMemedImage(_ sender: Any) {
        let memedImage = generateMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed:
        Bool, arrayReturnedItems: [Any]?, error: Error?) in
            if completed {
                print("share completed")
                self.saveMemedImage(memedImage)
                return
            } else {
                print("cancel")
            }
            if let shareError = error {
                print("error while sharing: \(shareError.localizedDescription)")
            }
        }
        present(activityViewController, animated: true, completion: nil)
    }
    
    func pickAnImage(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == topText || textField.text == bottomText {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            self.imageView.image = image
            //self.alignTextFielsdInImage(image)
            shareButton.isEnabled = true
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
//    func alignTextFielsdInImage(_ myImage: UIImage) {
//
//        let imageSize = self.imageView.image?.size
//        let imageAspectRatio: CGFloat = imageSize!.height / imageSize!.width
//
//        let frameSize = self.imageView.frame.size
//        let frameAspectRatio: CGFloat = frameSize.height / frameSize.width
//
//        var verticalConstant: CGFloat = 5.0
//        var horizontalConstant: CGFloat = 8.0
//
//        /* Compute the size of the image as seen on display (not in image pixels!) and
//            update the constraint constants for the textfields */
//        if imageAspectRatio > frameAspectRatio {
//            let scaledImageWidth = 1.0 / imageAspectRatio * frameSize.height
//            horizontalConstant += 0.5 * (frameSize.width - scaledImageWidth)
//        } else {
//            let scaledImageHeight = imageAspectRatio * frameSize.width
//            verticalConstant += 0.5 * (frameSize.height - scaledImageHeight)
//        }
//
//        // Adapt top and bottom textfield for the size of the chosen image
//        for constraint in self.view.constraints {
//            if constraint.identifier == "horizontalTextFieldConstraint" {
//                constraint.constant = horizontalConstant
//            } else if constraint.identifier == "verticalTextFieldConstraint" {
//                constraint.constant = verticalConstant
//            }
//        }
//        self.view.setNeedsUpdateConstraints()
//    }
}
