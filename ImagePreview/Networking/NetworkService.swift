//
//  NetworkService.swift
//  ImagePreview
//
//  Created by Max on 22.03.2021.
//

import Foundation

public typealias CodableCompletition<T: Codable> = (Result<T, Error>) -> Void
public typealias DataCompletition = (Result<Data, Error>) -> Void

public protocol NetworkServiceProtocol {
    func makeCodableRequest<T: Codable>(endpoint: Endpoint,
                                               completition: @escaping CodableCompletition<T>)
    func makeDataRequest(endpoint: Endpoint,
                                completition: @escaping DataCompletition)
}

class NetworkService: NetworkServiceProtocol {
    
    func makeDataRequest(endpoint: Endpoint, completition: @escaping DataCompletition) {
        NetworkService.makeRequest(endpoint: endpoint, completition: completition)
    }
    
    func makeCodableRequest<T: Codable>(endpoint: Endpoint,
                                        completition: @escaping CodableCompletition<T>) {
        NetworkService.makeRequest(endpoint: endpoint) { (result) in
            switch result {
            case .success(let data):
                guard let result = try? JSONDecoder().decode(T.self, from: data) else {
                    completition(.failure(NSError(domain: "Cannot decode data",
                                                  code: -1,
                                                  userInfo: nil)))
                    return
                }
                completition(.success(result))
            case .failure(let error):
                completition(.failure(error))
            }
        }
    }
        
    class func makeRequest(endpoint: Endpoint,
                           completition: @escaping DataCompletition) {
        guard let url = endpoint.url else {
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method
        
        let sesion = URLSession(configuration: .default)
        let dataTask = sesion.dataTask(with: urlRequest) { (data, response, error) in
            if let err = error {
                completition(.failure(err))
                return
            }
            
            guard response != nil, let data = data else {
                completition(.failure(NSError(domain: "Wrong data",
                                              code: -1,
                                              userInfo: nil)))
                return
            }
            
            completition(.success(data))
        }
        
        dataTask.resume()
    }
}
