//
//  NetworkService.swift
//  ImagePreview
//
//  Created by Max on 22.03.2021.
//

import Foundation

public protocol NetworkServiceProtocol {
    func requestPhoto(with text: String)
}

class NetworkService: NetworkServiceProtocol {

    func requestPhoto(with text: String) {
        let publicKey = searchKey
        let endpoint = FlickrEndpoint.search(publicKey: publicKey, query: text)
        SessionRequest().performTask(endpoint: endpoint) { response in
            switch response {
            case .success(let response):
                print(response)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
