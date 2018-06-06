//
//  IdeaTableViewController.swift
//  The Idea Pool
//
//  Created by Jason Bobier on 6/2/18.
//  Copyright © 2018 Jason Bobier. All rights reserved.
//

import UIKit

class IdeaTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var lightbulbImageView: UIImageView!
	@IBOutlet weak var gotIdeasLabel: UILabel!
	@IBOutlet weak var tableView: UITableView!
	
	var ideas: [Idea]!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if ideas.count == 0 {
			self.lightbulbImageView.isHidden = false
			self.gotIdeasLabel.isHidden = false
		} else {
			self.lightbulbImageView.isHidden = false
			self.gotIdeasLabel.isHidden = false
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.ideas.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		enum Tags: Int {
			case borderedView = 1
			case hairlineView = 2
			case contentLabel = 3
			case impactLabel = 4
			case easeLabel = 5
			case confidenceLabel = 6
			case avgLabel = 7
		}

		let idea = self.ideas[indexPath.row]
		let cell = tableView.dequeueReusableCell(withIdentifier: "IdeaCell", for: indexPath)
		
		let scale = UIScreen.main.scale
		let borderedViewLayer = cell.viewWithTag(Tags.borderedView.rawValue)!.layer
		
		borderedViewLayer.shadowOpacity = 0.33
		borderedViewLayer.shadowOffset = CGSize(width: 0, height: (3 / scale))
		borderedViewLayer.shadowRadius = (3 / scale)
		borderedViewLayer.cornerRadius = (5 / scale)
		
		cell.viewWithTag(Tags.hairlineView.rawValue)!.heightAnchor.constraint(equalToConstant: (1 / scale)).isActive = true
		(cell.viewWithTag(Tags.contentLabel.rawValue) as! UILabel).text = idea.content
		(cell.viewWithTag(Tags.impactLabel.rawValue) as! UILabel).text = String(idea.impact)
		(cell.viewWithTag(Tags.easeLabel.rawValue) as! UILabel).text = String(idea.ease)
		(cell.viewWithTag(Tags.confidenceLabel.rawValue) as! UILabel).text = String(idea.confidence)
		(cell.viewWithTag(Tags.avgLabel.rawValue) as! UILabel).text = String(idea.averageScore)

		return cell
	}
}
