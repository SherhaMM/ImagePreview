//
//  Endpoint.swift
//  ImagePreview
//
//  Created by Max on 22.03.2021.
//

import Foundation

let flickrBaseURL = "flickr.com"
let flickrGetPhotoURL = "live.staticflickr.com"

enum FlickrDestination: String {
    case flickrSearch = "flickr.photos.search"
}

struct FlickrEndpoint {
    let path: String
    let queryItems: [URLQueryItem]
}

extension FlickrEndpoint {
    static func search(publicKey: String,
                       query: String,
                       perPage: String? = "1",
                       page: String? = "1"
                       ) -> FlickrEndpoint {
        return FlickrEndpoint(
            path: "/services/rest/",
            queryItems: [
                URLQueryItem(name: "method", value: FlickrDestination.flickrSearch.rawValue),
                URLQueryItem(name: "api_key", value: publicKey),
                URLQueryItem(name: "text", value: query),
                URLQueryItem(name: "per_page", value: perPage),
                URLQueryItem(name: "page", value: page),
                URLQueryItem(name: "format", value: "json"),
                URLQueryItem(name: "nojsoncallback", value: "1"),
            ])
    }
}

extension FlickrEndpoint {
    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = flickrBaseURL
        components.path = path
        components.queryItems = queryItems
        return components.url
    }
}
