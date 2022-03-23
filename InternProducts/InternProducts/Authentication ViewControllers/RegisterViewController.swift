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
    
    private let httpService = HTTPService()
    
    
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
    /// Resgister Button Action
    ///
    @IBAction func register(_ sender: UIButton) {
        // if all textFields are NOT empty
        if username.text != "" && password.text != "" && confirmPassword.text != "" {
            // if passwords match
            if password.text == confirmPassword.text {
                passwordMismatchErrorLabel.isHidden = true
                // HTTP Register Request
                httpService.httpUserRequest(authenticationType: "register",
                                            username: username.text!,
                                            password: password.text!,
                                            action: { httpResultCases, message in
                    DispatchQueue.main.async {
                        switch httpResultCases {
                        case .error:
                            self.showAlert(withMessage: message)
                        case .responseFail:
                            self.showAlert(withMessage: message)
                        case .dataSuccess:
                            self.performSegue(withIdentifier: Constants.fromRegisterToTabBarController, sender: nil)
                        case .dataFail:
                            self.showAlert(withMessage: message)
                        }
                    }
                })
            } else {
                // passwords don't match
                passwordMismatchErrorLabel.isHidden = false
            }
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
