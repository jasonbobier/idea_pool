//
//  LogInViewController.swift
//  The Idea Pool
//
//  Created by Jason Bobier on 6/1/18.
//  Copyright © 2018 Jason Bobier. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var logInButton: UIButton!
	
		
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if let previousEmail = UserDefaults.standard.string(forKey: UserDefaultsKeys.previousEmailDefaultsKey), !previousEmail.isEmpty {
			self.emailTextField.text = previousEmail
			self.passwordTextField.becomeFirstResponder()
		} else {
			self.emailTextField.becomeFirstResponder()
		}
		
		self.update(self)
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		UserDefaults.standard.set(self.emailTextField.text, forKey: UserDefaultsKeys.previousEmailDefaultsKey)
	}
	
	@IBAction func update(_ sender: Any) {
		if let emailIsEmpty = self.emailTextField.text?.isEmpty, !emailIsEmpty, let passwordIsEmpty = self.passwordTextField.text?.isEmpty, !passwordIsEmpty {
			self.logInButton.isEnabled = true
			self.logInButton.alpha = 1
		} else {
			self.logInButton.isEnabled = false
			self.logInButton.alpha = 0.5
		}
	}
	
	@IBAction func resignTextFields(_ sender: Any) {
		self.view.endEditing(true)
	}
}

extension LogInViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		switch textField {
		case self.emailTextField:
			self.passwordTextField.becomeFirstResponder()
			
		case self.passwordTextField:
			textField.resignFirstResponder()
			
		default:
			break
		}
		
		return false
	}
}
