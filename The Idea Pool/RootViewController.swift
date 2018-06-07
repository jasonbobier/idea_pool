//
//  RootViewController.swift
//  The Idea Pool
//
//  Created by Jason Bobier on 6/1/18.
//  Copyright © 2018 Jason Bobier. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
	@IBOutlet weak var containerView: UIView!
	@IBOutlet weak var arrowImageView: UIImageView!
	@IBOutlet weak var arrowImageViewTrailingToLightBulbImageViewLeadingLayoutConstraint: NSLayoutConstraint!
	@IBOutlet weak var lightBulbImageView: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var logOutButton: UIButton!
	@IBOutlet weak var activityIndicatorBackgroundView: UIView!
	@IBOutlet weak var activityIndicatorView: UIView!
	
	var refreshToken: String?
	let apiBaseURL = URL(string: "https://small-project-api.herokuapp.com")!
	
	var activityIndicatorCount = 0 {
		didSet {
			if activityIndicatorCount == 0 {
				UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.25, delay: 0, animations: {
					self.activityIndicatorView.alpha = 0
				})
				UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.25, delay: 0.25, options: [], animations: {
					self.activityIndicatorBackgroundView.alpha = 0
				})
			} else {
				UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.25, delay: 0, options: [], animations: {
					self.activityIndicatorBackgroundView.alpha = 0.8
				})
				UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.25, delay: 0.25, options: [], animations: {
						self.activityIndicatorView.alpha = 1
				})
			}
		}
	}
	
	func showActivityIndicator(_ show: Bool) {
		DispatchQueue.main.async {
			self.activityIndicatorCount += show ? 1 : -1
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.updateHeader()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func show(_ vc: UIViewController, sender: Any?) {
		let oldVC = self.childViewControllers[0]
		
		oldVC.willMove(toParentViewController: nil)
		self.addChildViewController(vc)
		vc.view.frame = self.containerView.bounds
		self.updateHeader()
		self.transition(from: oldVC, to: vc, duration: 0.25, options: .transitionCrossDissolve, animations: nil) { (complete) in
			oldVC.removeFromParentViewController()
			vc.didMove(toParentViewController: self)
		}
	}
	
	override func showDetailViewController(_ vc: UIViewController, sender: Any?) {
		let oldVC = self.childViewControllers[0]
		
		self.addChildViewController(vc)
		vc.view.frame = self.containerView.bounds
		self.updateHeader()
		self.transition(from: oldVC, to: vc, duration: 0.25, options: .transitionCrossDissolve, animations: nil) { (complete) in
			vc.didMove(toParentViewController: self)
		}
	}
	
	override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
		guard (unwindSegue.source is IdeaEditorViewController) && (unwindSegue.destination is IdeaTableViewController) else {
			return
		}
		
		self.dismiss(from: unwindSegue.source, to: unwindSegue.destination)
	}
	
	func dismiss(from: UIViewController, to: UIViewController) {
		from.willMove(toParentViewController: nil)
		self.transition(from: from, to: to, duration: 0.25, options: .transitionCrossDissolve, animations: nil) { (complete) in
			from.removeFromParentViewController()
			self.updateHeader()
		}
	}
	
	func updateHeader() {
		if self.childViewControllers.last! is IdeaEditorViewController {
			UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.25, delay: 0, animations: {
				self.arrowImageView.alpha = 1
				self.lightBulbImageView.frame.origin.x = self.arrowImageView.frame.maxX + 20
				self.arrowImageViewTrailingToLightBulbImageViewLeadingLayoutConstraint.constant = 20
				self.titleLabel.alpha = 0
				self.logOutButton.alpha = 0
			})
		} else {
			UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.25, delay: 0, animations: {
				self.arrowImageView.alpha = 0
				self.lightBulbImageView.frame.origin.x = self.arrowImageView.frame.maxX - 8
				self.arrowImageViewTrailingToLightBulbImageViewLeadingLayoutConstraint.constant = -8
				self.titleLabel.alpha = 1
				if self.refreshToken == nil {
					self.logOutButton.alpha = 0
				} else {
					self.logOutButton.alpha = 1
				}
			})
		}
	}
	

	struct NetworkError {
		static let domain = "IdeaPoolNetworkingError"
		static let userAlreadyExists = NSError(domain: NetworkError.domain , code: 1, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("User already exists", comment: "User already exists error message")])
		static let badServerResponse = NSError(domain: NetworkError.domain , code: 1, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Bad server response", comment: "Bad server response error message")])
	}
	
	@IBAction func showError(_ error: NSError) {
		DispatchQueue.main.async {
			let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error alert title"), message: error.localizedDescription, preferredStyle: .alert)
			
			alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK error alert button"), style: .default, handler: nil))
			self.present(alert, animated: true)
		}
	}
	
	@IBAction func signUp(_ sender: Any) {
		if let signUpViewController = self.childViewControllers[0] as? SignUpViewController {
			self.signUp(email: signUpViewController.emailTextField.text!, name: signUpViewController.nameTextField.text!, password: signUpViewController.passwordTextField.text!)
		}
	}
	
	func signUp(email: String, name: String, password: String) {
		self.showActivityIndicator(true)
		
		var request = URLRequest(url: self.apiBaseURL.appendingPathComponent("users"))
		
		request.httpMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = try! JSONEncoder().encode(["email": email, "name": name, "password": password])
		
		var backgroundTask = UIBackgroundTaskInvalid
		
		backgroundTask = UIApplication.shared.beginBackgroundTask {
			UIApplication.shared.endBackgroundTask(backgroundTask)
			backgroundTask = UIBackgroundTaskInvalid
		}
		
		URLSession.shared.dataTask(with: request) { (data, response, error) in
			self.handleSignUpOrLogInResponse(data: data, response: response, error: error)
			UIApplication.shared.endBackgroundTask(backgroundTask)
			backgroundTask = UIBackgroundTaskInvalid
			self.showActivityIndicator(false)
		}.resume()
	}
	
	@IBAction func logIn(_ sender: Any) {
		if let logInViewController = self.childViewControllers[0] as? LogInViewController {
			self.logIn(email: logInViewController.emailTextField.text!, password: logInViewController.passwordTextField.text!)
		}
	}
	
	func logIn(email: String, password: String) {
		self.showActivityIndicator(true)

		var request = URLRequest(url: self.apiBaseURL.appendingPathComponent("access-tokens"))
		
		request.httpMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = try! JSONEncoder().encode(["email": email, "password": password])
		
		var backgroundTask = UIBackgroundTaskInvalid
		
		backgroundTask = UIApplication.shared.beginBackgroundTask {
			UIApplication.shared.endBackgroundTask(backgroundTask)
			backgroundTask = UIBackgroundTaskInvalid
		}
		
		URLSession.shared.dataTask(with: request) { (data, response, error) in
			self.handleSignUpOrLogInResponse(data: data, response: response, error: error)
			UIApplication.shared.endBackgroundTask(backgroundTask)
			backgroundTask = UIBackgroundTaskInvalid
			self.showActivityIndicator(false)
		}.resume()
	}
	
	func handleSignUpOrLogInResponse(data: Data?, response: URLResponse?, error: Error?) {
		if let error = error {
			self.showError(error as NSError)
		} else {
			if let data = data, let response = response as? HTTPURLResponse {
				if response.statusCode == 201 {
					if let json = try? JSONDecoder().decode([String:String].self, from: data) {
						let jwt = json["jwt"]
						let refreshToken = json["refresh_token"]
						
						if let jwt = jwt, let refreshToken = refreshToken {
							self.showActivityIndicator(true)
							DispatchQueue.main.async {
								self.refreshToken = refreshToken
								self.getIdeas(jwt: jwt)
								self.showActivityIndicator(false)
							}
						} else {
							self.showError(NetworkError.badServerResponse)
						}
					} else {
						self.showError(NetworkError.badServerResponse)
					}
				} else if response.statusCode == 422 {
					self.showError(NetworkError.userAlreadyExists)
				} else {
					self.showError(NetworkError.badServerResponse)
				}
			} else {
				self.showError(NetworkError.badServerResponse)
			}
		}
	}
	
	@IBAction func logOut(_ sender: Any) {
		if let refreshToken = self.refreshToken {
			self.refreshJWT(refreshToken: refreshToken) { (jwt, error) in
				if error == nil {
					var request = URLRequest(url: self.apiBaseURL.appendingPathComponent("access-tokens"))
					
					request.httpMethod = "DELETE"
					request.addValue("application/json", forHTTPHeaderField: "Content-Type")
					request.addValue(jwt!, forHTTPHeaderField: "X-Access-Token")
					request.httpBody = try! JSONEncoder().encode(["refresh_token": refreshToken])
					
					var backgroundTask = UIBackgroundTaskInvalid
					
					backgroundTask = UIApplication.shared.beginBackgroundTask {
						UIApplication.shared.endBackgroundTask(backgroundTask)
						backgroundTask = UIBackgroundTaskInvalid
					}
					
					URLSession.shared.dataTask(with: request) { (data, response, error) in
						if let error = error {
							debugPrint("Error logging out: \(error.localizedDescription)")
						} else {
							if let response = response as? HTTPURLResponse {
								if response.statusCode != 204 {
									debugPrint("Error logging out: \(response)")
								}
							} else {
								debugPrint("Error logging out: Didn't receive HTTPURLResponse")
							}
						}
						UIApplication.shared.endBackgroundTask(backgroundTask)
						backgroundTask = UIBackgroundTaskInvalid
						}.resume()
				} else {
					debugPrint("Error logging out: Couldn't refresh jwt")
				}
			}
			self.refreshToken = nil
		}
		self.show(self.storyboard!.instantiateViewController(withIdentifier: "LogInViewController"), sender: self)
	}
	
	func refreshJWT(refreshToken: String, completion: ((String?, Error?) -> Void)?) {
		var request = URLRequest(url: self.apiBaseURL.appendingPathComponent("access-tokens/refresh"))
		
		request.httpMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = try! JSONEncoder().encode(["refresh_token": refreshToken])
		
		var backgroundTask = UIBackgroundTaskInvalid
		
		backgroundTask = UIApplication.shared.beginBackgroundTask {
			UIApplication.shared.endBackgroundTask(backgroundTask)
			backgroundTask = UIBackgroundTaskInvalid
		}
		
		URLSession.shared.dataTask(with: request) { (data, response, error) in
			var error = error
			var jwt: String?
			
			if error == nil {
				if let data = data, let response = response as? HTTPURLResponse {
					if response.statusCode == 200 {
						if let json = try? JSONDecoder().decode([String:String].self, from: data) {
							jwt = json["jwt"]
							if jwt == nil {
								error = NetworkError.badServerResponse
							}
						} else {
							error = NetworkError.badServerResponse
						}
					} else {
						error = NetworkError.badServerResponse
					}
				} else {
					error = NetworkError.badServerResponse
				}
			}
			if error != nil {
				debugPrint("Error refreshing token: \(error!.localizedDescription)")
			}
			DispatchQueue.main.async {
				completion?(jwt, error)
			}
			UIApplication.shared.endBackgroundTask(backgroundTask)
			backgroundTask = UIBackgroundTaskInvalid
		}.resume()
	}
	
	func getIdeas(jwt: String) {
		var ideas = [Idea]()
		var urlComponents = URLComponents(url: self.apiBaseURL.appendingPathComponent("ideas"), resolvingAgainstBaseURL: false)!
		
		func getPageOfIdeas(page: Int) {
			self.showActivityIndicator(true)

			urlComponents.queryItems = [URLQueryItem(name: "page", value: String(page))]
			
			var request = URLRequest(url: urlComponents.url!)
			
			request.httpMethod = "GET"
			request.addValue("application/json", forHTTPHeaderField: "Content-Type")
			request.addValue(jwt, forHTTPHeaderField: "X-Access-Token")
			
			var backgroundTask = UIBackgroundTaskInvalid
			
			backgroundTask = UIApplication.shared.beginBackgroundTask {
				UIApplication.shared.endBackgroundTask(backgroundTask)
				backgroundTask = UIBackgroundTaskInvalid
			}
			
			URLSession.shared.dataTask(with: request) { (data, response, error) in
				if let error = error {
					self.showError(error as NSError)
				} else {
					if let data = data, let response = response as? HTTPURLResponse {
						if response.statusCode == 200 {
							if let someIdeas = try? JSONDecoder().decode([Idea].self, from: data) {
								if someIdeas.count == 0 {
									self.showActivityIndicator(true)
									DispatchQueue.main.async {
										let vc = self.storyboard!.instantiateViewController(withIdentifier: "IdeaTableViewController") as! IdeaTableViewController
										
										vc.ideas = ideas
										self.show(vc, sender: self)
										self.showActivityIndicator(false)
									}
								} else {
									ideas.append(contentsOf: someIdeas)
									getPageOfIdeas(page: page + 1)
								}
							} else {
								self.showError(NetworkError.badServerResponse)
							}
						} else {
							self.showError(NetworkError.badServerResponse)
						}
					} else {
						self.showError(NetworkError.badServerResponse)
					}
				}
				UIApplication.shared.endBackgroundTask(backgroundTask)
				backgroundTask = UIBackgroundTaskInvalid
				self.showActivityIndicator(false)
			}.resume()
		}
		
		getPageOfIdeas(page: 1)
	}
	
	@IBAction func saveIdea(_ sender: Any) {
		let count = self.childViewControllers.count

		if count > 1, let ideaEditorViewController = self.childViewControllers[count - 1] as? IdeaEditorViewController, let ideaTableViewController = self.childViewControllers[count - 2] as? IdeaTableViewController {
			if ideaEditorViewController.idea.id.isEmpty {
				self.createIdea(ideaEditorViewController: ideaEditorViewController, ideaTableViewController: ideaTableViewController)
			} else {
				self.updateIdea(ideaEditorViewController: ideaEditorViewController, ideaTableViewController: ideaTableViewController)
			}
		}
	}
	
	func createIdea(ideaEditorViewController: IdeaEditorViewController, ideaTableViewController: IdeaTableViewController) {
		if let refreshToken = self.refreshToken {
			self.showActivityIndicator(true)
			
			self.refreshJWT(refreshToken: refreshToken) { (jwt, error) in
				if error == nil {
					self.showActivityIndicator(true)
					
					var request = URLRequest(url: self.apiBaseURL.appendingPathComponent("ideas"))
					
					request.httpMethod = "POST"
					request.addValue("application/json", forHTTPHeaderField: "Content-Type")
					request.addValue(jwt!, forHTTPHeaderField: "X-Access-Token")
					request.httpBody = try! JSONEncoder().encode(ideaEditorViewController.idea)
					
					var backgroundTask = UIBackgroundTaskInvalid
					
					backgroundTask = UIApplication.shared.beginBackgroundTask {
						UIApplication.shared.endBackgroundTask(backgroundTask)
						backgroundTask = UIBackgroundTaskInvalid
					}
					
					URLSession.shared.dataTask(with: request) { (data, response, error) in
						if let error = error {
							self.showError(error as NSError)
						} else {
							if let data = data, let response = response as? HTTPURLResponse {
								if response.statusCode == 201 {
									if let idea = try? JSONDecoder().decode(Idea.self, from: data) {
										DispatchQueue.main.async {
											ideaTableViewController.insert(idea: idea)
											self.dismiss(from: ideaEditorViewController, to: ideaTableViewController)
										}
									} else {
										self.showError(NetworkError.badServerResponse)
									}
								} else {
									self.showError(NetworkError.badServerResponse)
								}
							} else {
								self.showError(NetworkError.badServerResponse)
							}
						}
						
						UIApplication.shared.endBackgroundTask(backgroundTask)
						backgroundTask = UIBackgroundTaskInvalid
						self.showActivityIndicator(false)
						}.resume()
				} else {
					self.showError(NetworkError.badServerResponse)
				}
				self.showActivityIndicator(false)
			}
		} else {
			self.showError(NetworkError.badServerResponse)
		}
	}

	func updateIdea(ideaEditorViewController: IdeaEditorViewController, ideaTableViewController: IdeaTableViewController) {
		if let refreshToken = self.refreshToken {
			self.showActivityIndicator(true)
			
			self.refreshJWT(refreshToken: refreshToken) { (jwt, error) in
				if error == nil {
					self.showActivityIndicator(true)
					
					var request = URLRequest(url: self.apiBaseURL.appendingPathComponent("ideas").appendingPathComponent(ideaEditorViewController.idea.id))
					
					request.httpMethod = "PUT"
					request.addValue("application/json", forHTTPHeaderField: "Content-Type")
					request.addValue(jwt!, forHTTPHeaderField: "X-Access-Token")
					request.httpBody = try! JSONEncoder().encode(ideaEditorViewController.idea)
					
					var backgroundTask = UIBackgroundTaskInvalid
					
					backgroundTask = UIApplication.shared.beginBackgroundTask {
						UIApplication.shared.endBackgroundTask(backgroundTask)
						backgroundTask = UIBackgroundTaskInvalid
					}
					
					URLSession.shared.dataTask(with: request) { (data, response, error) in
						if let error = error {
							self.showError(error as NSError)
						} else {
							if let data = data, let response = response as? HTTPURLResponse {
								if response.statusCode == 200 {
									if let idea = try? JSONDecoder().decode(Idea.self, from: data) {
										DispatchQueue.main.async {
											ideaTableViewController.insert(idea: idea)
											self.dismiss(from: ideaEditorViewController, to: ideaTableViewController)
										}
									} else {
										self.showError(NetworkError.badServerResponse)
									}
								} else {
									self.showError(NetworkError.badServerResponse)
								}
							} else {
								self.showError(NetworkError.badServerResponse)
							}
						}
						
						UIApplication.shared.endBackgroundTask(backgroundTask)
						backgroundTask = UIBackgroundTaskInvalid
						self.showActivityIndicator(false)
						}.resume()
				} else {
					self.showError(NetworkError.badServerResponse)
				}
				self.showActivityIndicator(false)
			}
		} else {
			self.showError(NetworkError.badServerResponse)
		}
	}
	
	@IBAction func deleteIdea(_ ideaTableViewController: IdeaTableViewController) {
		if let refreshToken = self.refreshToken {
			self.showActivityIndicator(true)
			
			self.refreshJWT(refreshToken: refreshToken) { (jwt, error) in
				if error == nil {
					self.showActivityIndicator(true)
					
					var request = URLRequest(url: self.apiBaseURL.appendingPathComponent("ideas").appendingPathComponent(ideaTableViewController.ideaToDelete!.id))
					
					request.httpMethod = "DELETE"
					request.addValue("application/json", forHTTPHeaderField: "Content-Type")
					request.addValue(jwt!, forHTTPHeaderField: "X-Access-Token")
					
					var backgroundTask = UIBackgroundTaskInvalid
					
					backgroundTask = UIApplication.shared.beginBackgroundTask {
						UIApplication.shared.endBackgroundTask(backgroundTask)
						backgroundTask = UIBackgroundTaskInvalid
					}
					
					URLSession.shared.dataTask(with: request) { (data, response, error) in
						if let error = error {
							self.showError(error as NSError)
						} else {
							if let response = response as? HTTPURLResponse {
								if response.statusCode == 204 {
									DispatchQueue.main.async {
										ideaTableViewController.delete(idea: ideaTableViewController.ideaToDelete!)
									}
								} else {
									self.showError(NetworkError.badServerResponse)
								}
							} else {
								self.showError(NetworkError.badServerResponse)
							}
						}
						
						UIApplication.shared.endBackgroundTask(backgroundTask)
						backgroundTask = UIBackgroundTaskInvalid
						self.showActivityIndicator(false)
						}.resume()
				} else {
					self.showError(NetworkError.badServerResponse)
				}
				self.showActivityIndicator(false)
			}
		} else {
			self.showError(NetworkError.badServerResponse)
		}
	}
}

