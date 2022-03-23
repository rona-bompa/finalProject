//
//  HTTPServices.swift
//  InternProducts
//
//  Created by Rona Bompa on 23.03.2022.
//

import Foundation

enum HTTPResultCases {
    case error
    case responseFail
    case dataSuccess
    case dataFail
}

class HTTPServices {

    public func httpUserRequest(authenticationType: String, username: String, password: String, action: @escaping (_: HTTPResultCases, _ : String) -> Void) {
        let urlSession = URLSession(configuration: .default)
        if let url = URL(string: "http://localhost:8080/\(authenticationType)?username=\(username)&password=\(password)") {
            let task = urlSession.dataTask(with: url) { data, response, error in
                //guard let self = self else { return }
                /// error
                if let error = error {
                    print("Request error received: \(error)")
                    action(HTTPResultCases.error, "\(error)")
                    /// response
                } else if let response = response as? HTTPURLResponse, response.statusCode != Constants.okHttpStatusCode {
                    action(HTTPResultCases.responseFail, "\(response)")
                    /// data
                } else if let data = data {
                    do {
                        guard let httpDataStatusResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String:String] else {
                            print("Data serialization error: Unexpected format received!")
                            return
                        }
                        // SUCCESS
                        if httpDataStatusResponse["status"] == "SUCCESS" {
                            // store & transmit in prepeare the logintToken
                            SessionVariables.loginToken = httpDataStatusResponse["loginToken"] ?? ""
                            // proceed to display the products to screen
                            action(HTTPResultCases.dataSuccess, "")
                        // FAIL
                        } else if httpDataStatusResponse["status"] == "FAILED" {
                            // display error message in an Alert
                            action(HTTPResultCases.dataFail, httpDataStatusResponse["message"] ?? "status: FAILED")
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

}

