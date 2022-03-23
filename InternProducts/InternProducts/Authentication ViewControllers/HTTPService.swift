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

class HTTPService {

    ///
    /// HTTP Login & Register Request
    ///
    public func httpUserRequest(authenticationType: String, username: String, password: String, action: @escaping (_: HTTPResultCases, _ : String) -> Void) {
        let urlSession = URLSession(configuration: .default)
        if let url = URL(string: "http://localhost:8080/\(authenticationType)?username=\(username)&password=\(password)") {
            let task = urlSession.dataTask(with: url) { data, response, error in
                //guard let self = self else { return }
                /// error
                if let error = error {
                    action(HTTPResultCases.error, "Request error received: \(error)")
                    /// response
                } else if let response = response as? HTTPURLResponse, response.statusCode != Constants.okHttpStatusCode {
                    action(HTTPResultCases.responseFail, "Expected 200 status code, but received: \(response.statusCode)")
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

    ///
    /// HTTP Get ProductsRequest
    ///
    public func httpGetProducts(action: @escaping (_: HTTPResultCases, _ : String, _: [Product]?) -> Void) {
        let urlSession = URLSession(configuration: .default)
        if let url = URL(string: "http://localhost:8080/products?loginToken=\(SessionVariables.loginToken)") {

            let task = urlSession.dataTask(with: url) { data, response, error in
                /// error
                if let error = error {
                    action(HTTPResultCases.error, "Request error received: \(error)", nil)
                    /// response
                } else if let response = response as? HTTPURLResponse, response.statusCode != Constants.okHttpStatusCode {
                    action(HTTPResultCases.responseFail, "Expected 200 status code, but received: \(response.statusCode)", nil)
                    /// data
                } else if let data = data {
                    // decoding data
                    let decoder = JSONDecoder()
                    guard let httpResponse = try? decoder.decode(Response.self, from: data) else {
                        print("Data serialization error: Unexpected format received!")
                        return
                    }
                    // if SUCCES, store in products
                    if httpResponse.status == "SUCCESS" {
                        guard let productsHttpResponse = httpResponse.products else {
                            print("No products returned")
                            return
                        }
                        action(HTTPResultCases.dataSuccess, "", productsHttpResponse)
                        // if FAILED, show message
                    } else if httpResponse.status == "FAILED" {
                        action(HTTPResultCases.dataFail, "Status: FAIED; Message: \(httpResponse.message!)", nil)
                    }
                } else {
                    print("Request error received:  Unexpected condition")
                }
            }
            task.resume()
        }
    }
}

