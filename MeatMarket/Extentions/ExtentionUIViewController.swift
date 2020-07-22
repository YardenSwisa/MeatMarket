//
//  ExtentionUIViewController.swift
//  MeatMarket
//
//  Created by YardenSwisa on 09/04/2020.
//  Copyright © 2020 YardenSwisa. All rights reserved.
//

import UIKit

extension UIViewController {
    
    //MARK: Hide keyboard when tapped on the View
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    //MARK: Dismiss Keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    //MARK: Observer on keybord, if its came out the view push up with him
    func observeKeybordForPushUpTheView() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    //MARK: Objc func for the Observer, Keyboard show/hide
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                print(keyboardSize.size.height)
                self.view.frame.origin.y -= keyboardSize.size.height / 2
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
}
