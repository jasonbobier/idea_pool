//
//  IdeaTableViewController.swift
//  The Idea Pool
//
//  Created by Jason Bobier on 6/2/18.
//  Copyright © 2018 Jason Bobier. All rights reserved.
//

import UIKit

// This table breaks interface by using what looks like a 'cell move control' as a button to bring up an action sheet. In a client app, I would argue to get rid
// of that button and just use a swipe control to delete and a tap to edit (possibly with a detail control). Also the movie showed two different animations
// for inserting a cell. One if the table was empty (a pop into place animation) and one if the table already had rows. I only did one animation for simplicity.
class IdeaTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var lightbulbImageView: UIImageView!
	@IBOutlet weak var gotIdeasLabel: UILabel!
	@IBOutlet weak var tableView: UITableView!
	
	var ideas = [Idea]()
	var ideaToDelete: Idea?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if ideas.count == 0 {
			self.lightbulbImageView.isHidden = false
			self.gotIdeasLabel.isHidden = false
		} else {
			self.lightbulbImageView.isHidden = true
			self.gotIdeasLabel.isHidden = true
		}
		
		// Magic number!! lol... I added this just because I was annoyed with the button covering some of the text in the cells. The correct way to do it is to adjust the content offset after
		// layout has finished.
		self.tableView.contentInset.bottom += 95
	}
	
	// We just remove a previous idea with the same id. It simplifies the case where the average would cause a reorder of the list.
	func insert(idea: Idea) {
		self.tableView?.beginUpdates()
		if let previousIndex = self.ideas.index(where: { $0.id == idea.id }) {
			self.ideas.remove(at: previousIndex)
			self.tableView?.deleteRows(at: [IndexPath(row: previousIndex, section: 0)], with: .automatic)
		}
		
		var index = self.ideas.index { idea.averageScore > $0.averageScore }
		
		if index == nil {
			index = self.ideas.count
		}
		self.ideas.insert(idea, at: index!)
		self.tableView?.insertRows(at: [IndexPath(row: index!, section: 0)], with: .automatic)
		self.tableView?.endUpdates()
	}
	
	func delete(idea: Idea) {
		if let previousIndex = self.ideas.index(where: { $0.id == idea.id }) {
			self.ideas.remove(at: previousIndex)
			self.tableView?.deleteRows(at: [IndexPath(row: previousIndex, section: 0)], with: .automatic)
		}
		self.ideaToDelete = nil
	}
	
	@IBAction func editOrDeleteIdea(_ sender: UIButton?) {
		let indexPath = self.tableView.indexPathForRow(at: sender!.convert(sender!.bounds.origin, to: self.tableView))!
		
		let actions = UIAlertController(title: nil, message: NSLocalizedString("Actions", comment: "Message for edit or delete alert controller"), preferredStyle: .actionSheet)
		
		actions.addAction(UIAlertAction(title: NSLocalizedString("Edit", comment:"Edit action title"), style: .default, handler: { (action) in
			let vc = self.storyboard!.instantiateViewController(withIdentifier: "IdeaEditorViewController") as! IdeaEditorViewController
			
			vc.idea = self.ideas[indexPath.row]
			self.showDetailViewController(vc, sender: self)
		}))
		actions.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: "Delete action title"), style: .destructive, handler: { (action) in
			let alert = UIAlertController(title: NSLocalizedString("Are you sure?", comment: "Are you sure alert title"), message: NSLocalizedString("This idea will be permanently deleted.", comment: "Are you sure alert message"), preferredStyle: .alert)
			
			// Note that this alert looks slightly different than the design because I used a standard alert.
			alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK Alert button"), style: .default, handler: { (action) in
				self.ideaToDelete = self.ideas[indexPath.row]
				
				// Let's let the responder chain handle it
				UIApplication.shared.sendAction(#selector(RootViewController.deleteIdea), to: nil, from: self, for: nil)
			}))
			alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel action title"), style: .cancel, handler: nil))
			self.present(alert, animated: true, completion: nil)
		}))
		actions.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel action title"), style: .cancel, handler: nil))
		
		self.present(actions, animated: true, completion: nil)
	}
	
	// Enums don't work well in practice even though they do in conception because you have to access the raw value (or provide a constructor from Tag to Int). At this years WWDC, I saw that
	// the cocoa team has started using structs with typealiases and then static consts. That looks interesting.
	enum Tags: Int {
		case borderedView = 1
		case hairlineView = 2
		case contentLabel = 3
		case impactLabel = 4
		case easeLabel = 5
		case confidenceLabel = 6
		case avgLabel = 7
	}

	func set(idea: Idea, for cell: UITableViewCell) {
		(cell.viewWithTag(Tags.contentLabel.rawValue) as! UILabel).text = idea.content
		(cell.viewWithTag(Tags.impactLabel.rawValue) as! UILabel).text = String(idea.impact)
		(cell.viewWithTag(Tags.easeLabel.rawValue) as! UILabel).text = String(idea.ease)
		(cell.viewWithTag(Tags.confidenceLabel.rawValue) as! UILabel).text = String(idea.confidence)
		(cell.viewWithTag(Tags.avgLabel.rawValue) as! UILabel).text = NumberFormatter.localizedString(from: idea.averageScore as NSNumber, number: .decimal)
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.ideas.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let idea = self.ideas[indexPath.row]
		let cell = tableView.dequeueReusableCell(withIdentifier: "IdeaCell", for: indexPath)
		
		
		// This is a bit wasteful. If I was worried about performance, I would just subclass UITableViewCell
		let borderedViewLayer = cell.viewWithTag(Tags.borderedView.rawValue)!.layer
		
		borderedViewLayer.shadowOpacity = 0.33
		borderedViewLayer.shadowOffset = CGSize(width: 0, height: 3)
		borderedViewLayer.shadowRadius = 3
		borderedViewLayer.cornerRadius = 5

		self.set(idea: idea, for: cell)
		
		return cell
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segue.identifier {
		case "addItem":
			(segue.destination as! IdeaEditorViewController).idea = Idea(id: "", content: "", impact: 10, ease: 10, confidence: 10)
		default:
			break
		}
	}
	
	@IBAction func closeIdeaEditor(seque: UIStoryboardSegue) {
		
	}
}
