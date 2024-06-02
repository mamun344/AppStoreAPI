//
//  API.swift
//  Mamun
//
//  Created by Mamun on 27/5/24.
//  Copyright © 2023 Mamun. All rights reserved.
//

import Foundation

public enum HttpMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}


public final class API: NSObject {
    
    private let retryDuration = 0.5
    private let maxRetry = 3
    private var retryCount = 0

    private lazy var session: URLSession = {
        URLSession.shared
    }()
    
    
    public func request(_ urlString    : String,
                        method         : HttpMethod = .get,
                        parameters     : [String: Any] = [:],
                        bodyData       : Data? = nil,
                        headers        : [String: String] = [:],
                        retry          : Bool = false,
                        completion     : @escaping((_ data: Data?, _ code: Int, _ success: Bool)->())) {
                
        guard var url = URL(string: urlString) else {
            completion(nil, -1, false)
            return
        }
        
        if method == .get, parameters.count > 0 {
            guard var components = URLComponents(string: urlString) else {
                completion(nil, -1, false)
                return
            }
            
            components.queryItems = parameters.compactMap { parm -> URLQueryItem? in
                if let value = parm.value as? String {
                    return URLQueryItem(name: parm.key, value: value)
                }
                else {
                    return URLQueryItem(name: parm.key, value: (parm.value as AnyObject).description)
                }
            }
            
            guard let _url = components.url else {
                completion(nil, -1, false)
                return
            }
            
            url = _url
        }
        
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        for (key, value) in headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        var jsonData: Data?
        
        if method != .get {
            if let bodyData {
                jsonData = bodyData
            }
            else {
                jsonData = jsonDataFrom(dic: parameters)
            }
            
            request.httpBody = jsonData
        }
        
        logRequest(request, url: url, jsonData: jsonData, headers: request.allHTTPHeaderFields ?? [:])
        
        let task = session.dataTask(with: request) { data, response, error in
            self.retryCount += 1
            
            self.logResponse(data: data, ofURL: url.absoluteString)
            
            DispatchQueue.main.async {
                let code = (response as? HTTPURLResponse)?.statusCode ?? 0
               
                if retry, self.retryCount < self.maxRetry {
                    DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + self.retryDuration) { [weak self] in
                        if let weakSelf = self {
                            weakSelf.request(urlString, method: method, parameters: parameters, headers: headers, retry: true, completion: completion)
                        }
                    }
                }
                else {
                    self.retryCount = 0
                    completion(data, code, code >= 200 && code < 300)
                }
            }
        }
        
        task.resume()
    }
    
    private func jsonDataFrom(dic: Any)->Data? {
        try? JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
    }
    
    func jsonFrom(data: Data)->Any? {
        try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
    }
    
    private func logRequest(_ request: URLRequest, url: URL, jsonData: Data?, headers: [String: String]) {
        #if DEBUG
        print("\nREQUEST ::>>>\n")

        print("URL: ", url)
        
        print("\nHEADERS ::>>>\n")
        
        for (key, value) in headers {
            print("\(key) : \(value)")
        }
        
        if let jsonData = jsonData, let reqJson = jsonFrom(data: jsonData) {
            print("\nBody : \n", reqJson)
        }
        
        print("\nCURL ::>>>\n")
        print(request.cURL(pretty: true), "\n")
        
        #endif
    }
    
    private func logRequest(url: String, json: [String: Any]?, headers: [String: String]?) {
        #if DEBUG
        print("\nREQUEST ::>>>\n")
        print("URL: " + url)
        
        print("\nHEADERS ::>>>\n")
        
        for (key, value) in (headers ?? [:]) {
            print("\(key) : \(value)")
        }
        
        if let json {
            print("\nBody : \n", json)
        }
        #endif
    }
    
    private func logResponse(data: Data?, ofURL url: String){
        #if DEBUG
        print("\n\n****   RESPONSE   ****\n")
        print("URL : ", url + "\n")
        
        if let data = data {
            if let json = self.jsonFrom(data: data) {
                print("JSON : \n", json)
            }
            else if let responseString = String.init(data: data, encoding: .utf8) {
                print("String : \n", responseString)
            }
            else {
                print("Non formatted data")
            }
        }
        else {
            print("No Data Found")
        }
        
        print("\n-----  =======   -----\n\n")
        #endif
    }
}


extension URLRequest {
    func cURL(pretty: Bool = false) -> String {
        let newLine = pretty ? "\\\n" : ""
        let method = (pretty ? "--request " : "-X ") + "\(self.httpMethod ?? "GET") \(newLine)"
        let url: String = (pretty ? "--url " : "") + "\'\(self.url?.absoluteString ?? "")\' \(newLine)"
        
        var cURL = "curl "
        var header = ""
        var data: String = ""
        
        if let httpHeaders = self.allHTTPHeaderFields, httpHeaders.keys.count > 0 {
            for (key,value) in httpHeaders {
                header += (pretty ? "--header " : "-H ") + "\'\(key): \(value)\' \(newLine)"
            }
        }
        
        if let bodyData = self.httpBody, let bodyString = String(data: bodyData, encoding: .utf8),  !bodyString.isEmpty {
            data = "--data '\(bodyString)'"
        }
        
        cURL += method + url + header + data
        
        return cURL
    }
}


