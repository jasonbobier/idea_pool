//
//  IdeaEditorViewController.swift
//  The Idea Pool
//
//  Created by Jason Bobier on 6/2/18.
//  Copyright © 2018 Jason Bobier. All rights reserved.
//

import UIKit

class IdeaEditorViewController: UIViewController, UIPopoverPresentationControllerDelegate {
	@IBOutlet weak var contentTextView: UITextView!
	@IBOutlet weak var impactValueLabel: UILabel!
	@IBOutlet weak var easeValueLabel: UILabel!
	@IBOutlet weak var confidenceValueLabel: UILabel!
	@IBOutlet weak var avgValueLabel: UILabel!
	@IBOutlet weak var saveButton: UIButton!
	
	var idea: Idea!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.contentTextView.text = self.idea.content
		self.impactValueLabel.text = String(self.idea.impact)
		self.easeValueLabel.text = String(self.idea.ease)
		self.confidenceValueLabel.text = String(self.idea.confidence)
		self.avgValueLabel.text = String(self.idea.averageScore)
		
		self.contentTextView.becomeFirstResponder()
		self.update(self)
	}
	
	@IBAction func update(_ sender: Any) {
		if let contentIsEmpty = self.contentTextView.text?.isEmpty, !contentIsEmpty {
			self.saveButton.isEnabled = true
			self.saveButton.alpha = 1
		} else {
			self.saveButton.isEnabled = false
			self.saveButton.alpha = 0.5
		}
	}
	
	@IBAction func resignTextFields(_ sender: Any) {
		self.view.endEditing(true)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case "popOver":
			segue.destination.modalPresentationStyle = .popover
			segue.destination.popoverPresentationController!.delegate = self
			segue.destination.popoverPresentationController!.sourceView = sender as! UIButton
			segue.destination.popoverPresentationController!.sourceRect = (sender as! UIButton).bounds
		default:
			break
		}
	}
	
	func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		return .none
	}
}
