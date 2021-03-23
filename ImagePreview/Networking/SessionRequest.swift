//
//  SessionRequest.swift
//  ImagePreview
//
//  Created by Max on 22.03.2021.
//

import Foundation

//class SessionRequest {
//    let session = URLSession.shared
//
//
//    public func performTask(endpoint: FlickrEndpoint,
//                            completition: @escaping (Result<PhotosSearchResult,Error>) -> Void) {
//        guard let url = endpoint.url else {
//            completition(.failure(NSError(domain: "Invalid URL",
//                                          code: -1,
//                                          userInfo: nil)))
//            return
//        }
//
//        let task = session.dataTask(with: url) { (data, response, error) in
//            guard error == nil else {
//                completition(.failure(NSError(domain: error?.localizedDescription ?? "Some error",
//                                              code: -1,
//                                              userInfo: nil)))
//                return
//            }
//
//            guard let data = data,
//                  let jsonData = try? JSONDecoder().decode(PhotosSearchResult.self,
//                                                  from: data) else {
//                completition(.failure(NSError(domain: "Malformed json",
//                                              code: -1,
//                                              userInfo: nil)))
//                return
//            }
//
//            completition(.success(jsonData))
//        }
//
//        task.resume()
//    }
//}


