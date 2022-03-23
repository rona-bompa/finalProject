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

    private let httpServices = HTTPServices()
    
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
            if let cvc = segue.destination as? TabBarController {
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
            httpServices.httpUserRequest(authenticationType: "login", username: username.text!, password: password.text!, action: { hTTPResultCases, message in
                switch hTTPResultCases {
                case .error:
                    DispatchQueue.main.async {
                        self.showAlert(withMessage: "Request error received: \(message)")
                    }
                case .responseFail:
                        DispatchQueue.main.async {
                            self.showAlert(withMessage: "Expected 200 status code, but received: \(message)")
                    }
                case .dataSuccess:
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: Constants.fromLoginToTabBarController, sender: nil)
                    }
                case .dataFail:
                    DispatchQueue.main.async {
                        self.showAlert(withMessage: message)
                    }
                }
            })
        }
    }
    
    // MARK: - Functions
    
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
