//
//  IdeaEditorViewController.swift
//  The Idea Pool
//
//  Created by Jason Bobier on 6/2/18.
//  Copyright © 2018 Jason Bobier. All rights reserved.
//

import UIKit

// Here we use a delegate for all of the checking... actually, we have to since UITextView doesn't pass value changed actions.

class IdeaEditorViewController: UIViewController, UIPopoverPresentationControllerDelegate {
	@IBOutlet weak var contentTextView: UITextView!
	@IBOutlet weak var impactButton: UIButton!
	@IBOutlet weak var impactValueLabel: UILabel!
	@IBOutlet weak var easeButton: UIButton!
	@IBOutlet weak var easeValueLabel: UILabel!
	@IBOutlet weak var confidenceButton: UIButton!
	@IBOutlet weak var confidenceValueLabel: UILabel!
	@IBOutlet weak var avgValueLabel: UILabel!
	@IBOutlet weak var saveButton: UIButton!
	
	var idea: Idea!
	var popoverButton: UIButton?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.contentTextView.text = self.idea.content
		self.impactValueLabel.text = String(self.idea.impact)
		self.easeValueLabel.text = String(self.idea.ease)
		self.confidenceValueLabel.text = String(self.idea.confidence)
		self.avgValueLabel.text = NumberFormatter.localizedString(from: self.idea.averageScore as NSNumber, number: .decimal)
		
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
			self.popoverButton = sender as? UIButton
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
	
	@IBAction func popOverValueSelected(segue: UIStoryboardSegue) {
		if let popoverButton = self.popoverButton, let row = (segue.source as! UITableViewController).tableView.indexPathForSelectedRow?.row {
			let value = row + 1
			switch popoverButton {
			case self.impactButton:
				self.idea.impact = value
				self.impactValueLabel.text = String(value)

			case self.easeButton:
				self.idea.ease = value
				self.easeValueLabel.text = String(value)

			case self.confidenceButton:
				self.idea.confidence = value
				self.confidenceValueLabel.text = String(value)

			default:
				break;
			}
			
			self.avgValueLabel.text = NumberFormatter.localizedString(from: self.idea.averageScore as NSNumber, number: .decimal)
		}
	}
}

extension IdeaEditorViewController: UITextViewDelegate {
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		guard let textViewText = textView.text, let range = Range(range, in: textViewText) else {
			return false
		}
		
		guard (textViewText.count - textViewText[range].count + text.count) < 256 else {
			return false
		}
		
		return true
	}
	
	func textViewDidChange(_ textView: UITextView) {
		self.idea.content = textView.text
		self.update(self)
	}
}
