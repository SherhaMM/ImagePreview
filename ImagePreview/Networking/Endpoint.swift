//
//  Router.swift
//  ImagePreview
//
//  Created by Max on 23.03.2021.
//

import Foundation

let flickrBaseURL = "flickr.com"
let getPhotoURL = "live.staticflickr.com"

public enum Endpoint {
    case searchPhotosByQuery(query: String,
                             countPerPage: String,
                             pageNumber: String)
    case getPhoto(serverId: String,
                  id: String,
                  secret: String)
}

extension Endpoint {
    var scheme: String {
        switch self {
        case .getPhoto,.searchPhotosByQuery:
            return "https"
        }
    }
    
    var host: String {
        switch self {
        case .getPhoto:
            return getPhotoURL
        case .searchPhotosByQuery:
            return flickrBaseURL
        }
    }
    
    var path: String {
        switch self {
        case .getPhoto(let serverId,let id,let secret):
            return "/\(serverId)/\(id)_\(secret).jpg"
        case .searchPhotosByQuery:
            return "/services/rest/"
        }
    }
    
    var parameters: [URLQueryItem]? {
        let accessToken = searchKey
        switch self {
        case .getPhoto:
            return nil
        case .searchPhotosByQuery(let query,let countPerPage, let pageNum):
            return [
                URLQueryItem(name: "method", value: "flickr.photos.search"),
                URLQueryItem(name: "api_key", value: accessToken),
                URLQueryItem(name: "text", value: query),
                URLQueryItem(name: "per_page", value: countPerPage),
                URLQueryItem(name: "page", value: pageNum),
                URLQueryItem(name: "format", value: "json"),
                URLQueryItem(name: "nojsoncallback", value: "1"),
            ]
        }
    }
    
    var method: String {
        switch self {
        case .getPhoto, .searchPhotosByQuery:
            return "GET"
        }
    }
}

extension Endpoint {
    var url: URL? {
        var components = URLComponents()
        components.scheme = self.scheme
        components.host = self.host
        components.path = self.path
        components.queryItems = self.parameters
        return components.url
    }
}
