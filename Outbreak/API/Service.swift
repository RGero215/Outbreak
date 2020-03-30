//
//  Service.swift
//  Outbreak
//
//  Created by Ramon Geronimo on 3/28/20.
//  Copyright © 2020 Ramon Geronimo. All rights reserved.
//

import Alamofire

class Service: NSObject {
    
    static let shared = Service()
    
//    let baseUrl = "http://127.0.0.1:1337"
    let baseUrl = "https://outbreaks.herokuapp.com"
    
    func searchForUsers(completion: @escaping (AFResult<[User]>) -> ()) {
        let url = "\(baseUrl)/search"
        AF.request(url)
            .validate(statusCode: 200..<300)
            .responseData { (dataResponse) in
                if let err = dataResponse.error {
                    completion(.failure(err))
                    return
                }
                
                do {
                    let data = dataResponse.data ?? Data()
                    let users = try JSONDecoder().decode([User].self, from: data)
                    completion(.success(users))
                } catch {
                    guard let url = dataResponse.error?.url else {return}
                    completion(.failure(AFError.responseSerializationFailed(reason: .inputFileReadFailed(at: url))))
                }
        }
    }
    
    func login(email: String, password: String, completion: @escaping (AFResult<Data>) -> ()) {
        print("Performing login")
        let params = ["emailAddress": email, "password": password]
        let url = "\(baseUrl)/api/v1/entrance/login"
        AF.request(url, method: .put, parameters: params)
            .validate(statusCode: 200..<300)
            .responseData { (dataResp) in
                if let err = dataResp.error {
                    completion(.failure(err))
                } else {
                    completion(.success(dataResp.data ?? Data()))
                }
        }
    }
    
    func fetchPosts(completion: @escaping (AFResult<[Post]>) -> ()) {
        let url = "\(baseUrl)/post"
        AF.request(url)
            .validate(statusCode: 200..<300)
            .responseData { (dataResp) in
                if let err = dataResp.error {
                    completion(.failure(err))
                    return
                }
                
                guard let data = dataResp.data else { return }
                do {
                    let posts = try JSONDecoder().decode([Post].self, from: data)
                    completion(.success(posts))
                } catch {
                    guard let url = dataResp.error?.url else {return}
                    completion(.failure(AFError.responseSerializationFailed(reason: .inputFileReadFailed(at: url))))
                }
        }
    }
    
    func signUp(fullName: String, emailAddress: String, password: String, completion: @escaping (AFResult<Data>) -> ()) {
        let params = ["fullName": fullName, "emailAddress": emailAddress, "password": password]
        let url = "\(baseUrl)/api/v1/entrance/signup"
        AF.request(url, method: .post, parameters: params)
            .validate(statusCode: 200..<300)
            .responseData { (dataResp) in
                if let err = dataResp.error {
                    completion(.failure(err))
                    return
                }
                completion(.success(dataResp.data ?? Data()))
        }
    }
    
}
