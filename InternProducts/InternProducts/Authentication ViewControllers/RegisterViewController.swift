//
//  RegisterViewController.swift
//  InternProducts
//
//  Created by Rona Bompa on 11.03.2022.
//

import UIKit

class RegisterViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var passwordMismatchErrorLabel: UILabel!
    
    // MARK: - Overrides
    
    ///
    /// View Did Load
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        
        password.isSecureTextEntry = true
        confirmPassword.isSecureTextEntry = true
        passwordMismatchErrorLabel.isHidden = true
    }
    
    // MARK: - Button Actions
    
    ///
    /// Resgister Button Action
    ///
    @IBAction func register(_ sender: UIButton) {
        // if all textFields are NOT empty
        if username.text != "" && password.text != "" && confirmPassword.text != "" {
            // if the passwords match
            if password.text == confirmPassword.text {
                passwordMismatchErrorLabel.isHidden = true
                // HTTP Register Request
                httpRegisterUser()
            } else {
                // passwords don't match
                passwordMismatchErrorLabel.isHidden = false
            }
        }
    }
    
    // MARK: - Functions
    
    ///
    /// HTTP Register User
    ///
    private func httpRegisterUser() {
        let urlSession = URLSession(configuration: .default)
        if let url = URL(string: "http://localhost:8080/register?username=\(username.text!)&password=\(password.text!)") {
            /// closure apelat pe background thread by default
            let task = urlSession.dataTask(with: url) { [weak self] data, response, error in
                guard let self = self else { return } /// sa nu avem self?.___ si nici retainCount + 1
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
                                // TODO: Maybe store the login Token?
                                // proceed to display the products to screen
                                self.performSegue(withIdentifier: Constants.fromRegisterToProducts, sender: nil)
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
