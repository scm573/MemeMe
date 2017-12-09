//
//  ViewController.swift
//  MemeMe
//
//  Created by Wu, Qifan | Keihan | ECID on 2017/12/06.
//

import UIKit

class MemeEditorViewController: UIViewController {
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    enum ImagePickerType: Int { case album = 0, camera }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.bringSubview(toFront: topToolbar)
        view.bringSubview(toFront: bottomToolbar)
        customize(textField: topTextField)
        customize(textField: bottomTextField)
        topTextField.delegate = self
        bottomTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        shareButton.isEnabled = imagePickerView.image != nil
        cancelButton.isEnabled = imagePickerView.image != nil
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeFromKeyboardNotifications()
        super.viewWillDisappear(animated)
    }
    
    @IBAction func pickImage(_ sender: UIBarButtonItem) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        switch(ImagePickerType(rawValue: sender.tag)!) {
        case .album:
            pickerController.sourceType = .photoLibrary
        case .camera:
            pickerController.sourceType = .camera
        }
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func share(_ sender: Any) {
        let activityItem = [generateMemedImage() as AnyObject]
        let avc = UIActivityViewController(activityItems: activityItem, applicationActivities: nil)
        avc.completionWithItemsHandler = {(activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed { return }
            self.save()
            self.dismiss(animated: true, completion: nil)
        }
        present(avc, animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        imagePickerView.image = nil
        shareButton.isEnabled = false
        cancelButton.isEnabled = false
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        topTextField.isEnabled = false
        bottomTextField.isEnabled = false
    }
}

// MARK: ImagePicker
extension MemeEditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
            topTextField.isEnabled = true
            bottomTextField.isEnabled = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: TextField
extension MemeEditorViewController: UITextFieldDelegate {
    func customize(textField: UITextField) {
        let memeTextAttributes: [String: Any] = [
            NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
            NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedStringKey.strokeWidth.rawValue: -5
        ]
        
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "TOP" { topTextField.text?.removeAll() }
        if textField.text == "BOTTOM" { bottomTextField.text?.removeAll() }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: Handle keyboard
extension MemeEditorViewController {
    @objc func keyboardWillShow(_ notification:Notification) {
        if topTextField.isFirstResponder {
            view.frame.origin.y = 0 - topToolbar.frame.height
        } else if bottomTextField.isFirstResponder {
            view.frame.origin.y = 0 - getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
}

// MARK: Generate Meme
extension MemeEditorViewController {
    struct Meme {
        var topText: String,
        bottomText: String,
        originalImage: UIImage,
        memedImage: UIImage
    }
    
    func generateMemedImage() -> UIImage {
        configureBars(hidden: true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        configureBars(hidden: false)
        
        return memedImage
    }
    
    func save() {
        let meme = Meme(
            topText: topTextField.text ?? "",
            bottomText: bottomTextField.text ?? "",
            originalImage: imagePickerView.image ?? UIImage(),
            memedImage: generateMemedImage()
        )
    }
    
    private func configureBars(hidden: Bool) {
        navigationController?.setToolbarHidden(hidden, animated: false)
        topToolbar.isHidden = hidden
        bottomToolbar.isHidden = hidden
    }
}
