//
//  SignUpViewController.swift
//  The Idea Pool
//
//  Created by Jason Bobier on 6/1/18.
//  Copyright © 2018 Jason Bobier. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var warningLabel: UILabel!
	@IBOutlet weak var signUpButton: UIButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.update(self)
	}
	
	@IBAction func update(_ sender: Any) {
		if let nameIsEmpty = self.nameTextField.text?.isEmpty, !nameIsEmpty, let emailIsEmpty = self.emailTextField.text?.isEmpty, !emailIsEmpty, self.validatePassword() {
			self.signUpButton.isEnabled = true
			self.signUpButton.alpha = 1
		} else {
			self.signUpButton.isEnabled = false
			self.signUpButton.alpha = 0.5
		}
	}
	
	func validatePassword() -> Bool {
		var result = false
		
		if let passwordText = self.passwordTextField.text, !passwordText.isEmpty {
			if passwordText.count < 8 {
				self.warningLabel.isHidden = false
				self.warningLabel.text = NSLocalizedString("Password is too short", comment: "Sign on password too short warning")
			} else if !passwordText.unicodeScalars.contains { CharacterSet.uppercaseLetters.contains($0) } {
				self.warningLabel.isHidden = false
				self.warningLabel.text = NSLocalizedString("Password requires an uppercase letter", comment: "Sign on password requires uppercase letter warning")
			} else if !passwordText.unicodeScalars.contains { CharacterSet.lowercaseLetters.contains($0) } {
				self.warningLabel.isHidden = false
				self.warningLabel.text = NSLocalizedString("Password requires a lowercase letter", comment: "Sign on password requires lowercase letter warning")
			} else if !passwordText.unicodeScalars.contains { CharacterSet.decimalDigits.contains($0) } {
				self.warningLabel.isHidden = false
				self.warningLabel.text = NSLocalizedString("Password requires a number", comment: "Sign on password requires number warning")
			} else {
				result = true
				self.warningLabel.isHidden = true
			}
		} else {
			self.warningLabel.isHidden = true
		}
		
		return result
	}
	
	@IBAction func resignTextFields(_ sender: Any) {
		self.view.endEditing(true)
	}
}
