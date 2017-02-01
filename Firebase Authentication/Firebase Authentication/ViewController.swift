//
//  ViewController.swift
//  Firebase Authentication
//
//  Created by Annie Tung on 2/1/17.
//  Copyright © 2017 Annie Tung. All rights reserved.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var signinButton: UIButton!
    var activeField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerForKeyboardNotifications()
        updateInterface()
        addGestureToDissmissKeyboard()
    }
    
    func addGestureToDissmissKeyboard() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dissmissKeyboard))
        view.addGestureRecognizer(gesture)
    }
    
    func dissmissKeyboard() {
        view.endEditing(true)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        if let info = notification.userInfo,
            let sizeString = info[UIKeyboardFrameBeginUserInfoKey] as? NSValue {
            
            // get the size of the keyboard
            // Apple tells us to only look at its height
            let keyboardSize = sizeString.cgRectValue
            
            // insets are a way to offset content in a scrollview without changing the
            // content itself: inset ~ margin ~ offset
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            
            // the scrollview wasn't scrolling before because its content was smaller
            // than its frame and after the next line its content will be the same size
            // but it will become scroll*able* when we add an inset the size of the keyboard
            scrollView.contentInset = contentInsets
            
            // make sure the indicators (aka scrollbars)
            // reflect the new inset
            scrollView.scrollIndicatorInsets = contentInsets
            
            // All is well if the field we're on is already in view.
            // The page is now actively scrollable
            
            // this is the whole vc
            var rect = self.view.frame
            
            // this is the height above the keyboard
            rect.size.height -= keyboardSize.height
            
            if let field = activeField {
                // if the area above the keyboard doesn't intersect with the origin (top left)
                // of the current field scroll the whole field into view
                if !rect.contains(field.frame.origin) {
                    scrollView.scrollRectToVisible(field.frame, animated: true)
                }
            }
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        // put everything back to what it was before
        scrollView.contentInset = .zero;
        scrollView.scrollIndicatorInsets = .zero;
    }
    
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.passwordField {
            self.view.endEditing(true)
            return false
        }
        return true
    }
    
    private func updateInterface() {
        if let user = FIRAuth.auth()?.currentUser {
        self.userEmailLabel.text = user.email
        self.signinButton.setTitle("Sign Out", for: .normal)
        } else {
            self.userEmailLabel.text = ""
            self.signinButton.setTitle("Sign In", for: .normal)
        }
    }
    
    @IBAction func signingUp(_ sender: UIButton) {
        if let email = emailField.text,
            let password = passwordField.text {
            
            FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error: Error?) in
                if user != nil {
                    self.updateInterface()
                } else {
                    let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
        
    }
    
    @IBAction func signingIn(_ sender: UIButton) {
        if FIRAuth.auth()?.currentUser != nil {
            do {
                try FIRAuth.auth()?.signOut()
                self.updateInterface()
            } catch {
                print(error)
            }
        }
        else if let email = emailField.text,
            let password = passwordField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user: FIRUser?, error: Error?) in
                if user != nil {
                    self.updateInterface()
                } else {
                    let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
    }
}


