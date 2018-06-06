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
	@IBOutlet weak var logOutButton: UIButton!
	@IBOutlet weak var activityIndicatorBackgroundView: UIView!
	@IBOutlet weak var activityIndicatorView: UIView!
	
	var jwt: String?
	var refreshToken: String? {
		didSet {
			self.logOutButton.isHidden = (refreshToken == nil)
		}
	}
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
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func show(_ vc: UIViewController, sender: Any?) {
		let oldVC = self.childViewControllers[0]
		
		oldVC.willMove(toParentViewController: nil)
		self.addChildViewController(vc)
		vc.view.frame = self.containerView.bounds
		self.transition(from: oldVC, to: vc, duration: 0.25, options: .transitionCrossDissolve, animations: nil) { (complete) in
			oldVC.removeFromParentViewController()
			vc.didMove(toParentViewController: self)
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
							DispatchQueue.main.async {
								self.jwt = jwt
								self.refreshToken = refreshToken
								self.getIdeas()
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
		var request = URLRequest(url: self.apiBaseURL.appendingPathComponent("access-tokens"))
		
		request.httpMethod = "DELETE"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.addValue(self.jwt!, forHTTPHeaderField: "X-Access-Token")
		request.httpBody = try! JSONEncoder().encode(["refresh_token": self.refreshToken])
		
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
		self.jwt = nil
		self.refreshToken = nil
		self.show(self.storyboard!.instantiateViewController(withIdentifier: "LogInViewController"), sender: self)
	}
	
	func refreshJWT(completion: (() -> Void)?) {
		var request = URLRequest(url: self.apiBaseURL.appendingPathComponent("access-tokens/refresh"))
		
		request.httpMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = try! JSONEncoder().encode(["refresh_token": self.refreshToken])
		
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
						if let json = try? JSONDecoder().decode([String:String].self, from: data) {
							let jwt = json["jwt"]
							
							if let jwt = jwt {
								DispatchQueue.main.async {
									self.jwt = jwt
									completion?()
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
				} else {
					self.showError(NetworkError.badServerResponse)
				}
			}

			UIApplication.shared.endBackgroundTask(backgroundTask)
			backgroundTask = UIBackgroundTaskInvalid
		}.resume()
	}
	
	func getIdeas() {
		var ideas = [Idea]()
		var urlComponents = URLComponents(url: self.apiBaseURL.appendingPathComponent("ideas"), resolvingAgainstBaseURL: false)!
		
		func getPageOfIdeas(page: Int) {
			self.showActivityIndicator(true)

			urlComponents.queryItems = [URLQueryItem(name: "page", value: String(page))]
			
			var request = URLRequest(url: urlComponents.url!)
			
			request.httpMethod = "GET"
			request.addValue("application/json", forHTTPHeaderField: "Content-Type")
			request.addValue(self.jwt!, forHTTPHeaderField: "X-Access-Token")
			
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
}

