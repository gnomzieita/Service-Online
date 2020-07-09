//
//  SO_API.swift
//  Service Online
//
//  Created by Alex Agarkov on 2/27/19.
//  Copyright © 2019 YobiByte LLC. All rights reserved.
//
import Foundation
import Alamofire

class SO_API {
    static let shared = SO_API()
    
    private init(){}
    
    private let BASE_SERVER = "159.203.113.210"
    private let BASE_PORT = "27099"
    private let BASE_PROTOCOL = "http://"
    private var server_token = ""
    
    // MARK: ROUTE
    
    private func getBaseUrlString() -> String {
        return "\(BASE_PROTOCOL)\(BASE_SERVER):\(BASE_PORT)"
    }
    
    func getLoginUrl() -> URL {
        return URL(string: "\(getBaseUrlString())/login")!
    }
    
    
    // MARK: BASE REQUEST
    private func baseRequest(urlString:URL, method: HTTPMethod = .get, parameters: Parameters? = nil, headers: HTTPHeaders? = nil, completionHandler:@escaping CompletionHandler){
        
        var requestheaders: HTTPHeaders = [:]
        if let tmpParam = headers {
            requestheaders = tmpParam
            requestheaders["Origin"] = "bla"
        }
        
        if server_token.count > 0 {
            requestheaders["Authorization"] = "Bearer \(server_token)"
        }
        
        Alamofire.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: requestheaders)
            .downloadProgress(queue: DispatchQueue.global(qos: .utility)) { progress in
                print("Progress: \(progress.fractionCompleted)")
            }
            .validate { request, response, data in
                // Custom evaluation closure now includes data (allows you to parse data to dig out error messages if necessary)
                return .success
            }
            .responseJSON { response in
                
                if let result = response.result.value as? [String:AnyObject] {
                    if let success = result["success"], success.boolValue {
                        //debugPrint(success.boolValue)
                        completionHandler(true,result as AnyObject)
                    }
                    else if let error = result["error"] as? String
                    {
                        debugPrint(error)
                        self.showAlert("Error", message: error)
                    }
                }
                
                
        }
    }
    
    func showAlert(_ title : String, message : String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { action in
            // perhaps use action.title here
        })
        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
    }
    
    //typealias CompletionHandler = (_ result: [String: Any], _ error: Error) -> Void
    typealias CompletionHandler = (_ succeed: Bool?, _ response : AnyObject?) -> Void
    static var completionHandler: CompletionHandler?
    
    private func GET_Request (urlString:URL, parameters: Parameters? = nil, headers: HTTPHeaders? = nil, completionHandler:@escaping CompletionHandler)
    {
        baseRequest(urlString: urlString, method: .get, parameters: parameters, headers: headers, completionHandler: completionHandler)
    }
    
    private func POST_Request (urlString:URL, parameters: Parameters? = nil, completionHandler:@escaping CompletionHandler)
    {
        let requestheaders: HTTPHeaders = ["Content-Type":"application/json"]
        
        baseRequest(urlString: urlString, method: .post, parameters: parameters, headers: requestheaders, completionHandler: completionHandler)
    }
    
    func login(email: String, password: String, completionHandler:@escaping CompletionHandler) {
        
        let parameters: Parameters = ["email": email,"password": password]
        POST_Request(urlString: getLoginUrl(), parameters: parameters) { (success, response) in
            if success!, let responseDict = response as? [String:Any] {
                if let responseToken = responseDict["token"] as? String {
                    self.server_token = responseToken
                    completionHandler(true,response)
                }
                else
                {
                    debugPrint("Error: TOKEN NOT FOUND!!!")
                    completionHandler(false,response)
                }
            }
        }
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
