//
//  LoginViewController.swift
//  InternProducts
//
//  Created by Rona Bompa on 11.03.2022.
//

import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    // MARK: - Overrides
    
    ///
    /// View Did Load
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        password.isSecureTextEntry = true
    }

    ///
    /// Prepare for segue
    ///
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.fromRegisterToTabBarController {
            if let cvc = segue.destination as? UITabBarController {
                cvc.navigationItem.setHidesBackButton(true, animated: true)
            }
        }
    }
    
    // MARK: - Button Actions
    
    ///
    /// Login Button Action
    ///
    @IBAction func login(_ sender: UIButton) {
        // if all textFields are NOT empty
        if username.text != "" && password.text != "" {
            httpLoginUser()
        }
    }
    
    // MARK: - Functions
    ///
    /// HTTP Login User
    ///
    private func httpLoginUser() {
        let urlSession = URLSession(configuration: .default)
        if let url = URL(string: "http://localhost:8080/login?username=\(username.text!)&password=\(password.text!)") {
            let task = urlSession.dataTask(with: url) { [weak self] data, response, error in
                guard let self = self else { return }
                /// error
                if let error = error {
                    print("Request error received: \(error)")
                    DispatchQueue.main.async {
                        self.showAlert(withMessage: "\(error)")
                    }
                    /// response
                } else if let response = response as? HTTPURLResponse, response.statusCode != Constants.okHttpStatusCode {
                    DispatchQueue.main.async {
                        self.showAlert(withMessage: "Expected 200 status code, but received: \(response.statusCode)")
                    }
                    /// data
                } else if let data = data {
                    do {
                        guard let httpDataStatusResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String:String] else {
                            print("Data serialization error: Unexpected format received!")
                            return
                        }
                        
                        DispatchQueue.main.async {
                            // SUCCESS
                            if httpDataStatusResponse["status"] == "SUCCESS" {
                                // store & transmit in prepeare the logintToken
                                Constants.loginToken = httpDataStatusResponse["loginToken"] ?? ""
                                // proceed to display the products to screen
                                self.performSegue(withIdentifier: Constants.fromLoginToTabBarController, sender: nil)
                                // FAIL
                            } else if httpDataStatusResponse["status"] == "FAILED" {
                                // display error message in an Alert
                                self.showAlert(withMessage: httpDataStatusResponse["message"] ?? "status: FAILED")
                            }
                        }
                    } catch {
                        print("Data serialization error: \(error)")
                    }
                } else {
                    print("Request error received:  Unexpected condition")
                }
            }
            task.resume()
        }
    }
    
    ///
    /// Show Alert
    ///
    private func showAlert(withMessage message: String) {
        // create the alert
        let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertController.Style.alert)
        // add an action (button)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        present(alert, animated: true)
    }
}
