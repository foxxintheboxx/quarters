//
//  HTTPHelper.swift
//  Selfie
//
//  Created by Subhransu Behera on 18/11/14.
//  Copyright (c) 2014 subhb.org. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit

enum HTTPRequestAuthType {
    case httpBasicAuth
    case httpTokenAuth
}

enum HTTPRequestContentType {
    case httpJsonContent
    case httpMultipartContent
}

struct HTTPHelper {
    
    static let API_AUTH_NAME = ""
    static let API_AUTH_PASSWORD = ""
    static let BASE_URL = ""
    
    func buildRequest(_ path: String!, method: String, authType: HTTPRequestAuthType,
                      requestContentType: HTTPRequestContentType = HTTPRequestContentType.httpJsonContent, requestBoundary:String = "") -> NSMutableURLRequest {
        // 1. Create the request URL from path
        let requestURL = URL(string: "\(HTTPHelper.BASE_URL)/\(path)")
        let request = NSMutableURLRequest(url: requestURL!)
        
        // Set HTTP request method and Content-Type
        request.httpMethod = method
        
        // 2. Set the correct Content-Type for the HTTP Request. This will be multipart/form-data for photo upload request and application/json for other requests in this app
        switch requestContentType {
        case .httpJsonContent:
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        // 3. Set the correct Authorization header.
        switch authType {
        case .httpTokenAuth:
            // Retreieve Auth_Token from FB
            if let userToken = FBSDKAccessToken.current().tokenString as String? {
                // Set Authorization header
                request.addValue("Token token=\(userToken)", forHTTPHeaderField: "Authorization")
            }
        }
        
        return request
    }
    
    
    func sendRequest(_ request: URLRequest, completion:@escaping (Data?, NSError?) -> Void) -> () {
        // Create a NSURLSession task
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: NSError?) in
            if error != nil { //error
                DispatchQueue.main.async(execute: { () -> Void in
                    completion(data, error)
                })
                
                return
            }
            //no error
            DispatchQueue.main.async(execute: { () -> Void in
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        completion(data, nil)
                    } else {
                        do {
                            //var jsonerror:NSError?
                            if let errorDict = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary {
                                let responseError : NSError = NSError(domain: "HTTPHelperError", code: httpResponse.statusCode, userInfo: errorDict as? [AnyHashable: Any])
                                completion(data, responseError)
                            }
                            
                        }
                        catch let error as NSError {
                            print(error.localizedDescription)
                        }
                        
                    }
                }
            })
            } as! (Data?, URLResponse?, Error?) -> Void)
        
        // start the task
        task.resume()
    }
    
    func getErrorMessage(_ error: NSError) -> NSString {
        var errorMessage : NSString
        
        // return correct error message
        if error.domain == "HTTPHelperError" {
            let userInfo = error.userInfo as NSDictionary!
            errorMessage = userInfo?.value(forKey: "message") as! NSString
        } else {
            errorMessage = error.description as NSString
        }
        
        return errorMessage
    }
}
