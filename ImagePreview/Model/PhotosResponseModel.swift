//
//  FlickrResponseModel.swift
//  ImagePreview
//
//  Created by Max on 23.03.2021.
//

import Foundation


// MARK: - Welcome
public struct SearchResponse: Codable {
    let photos: Photos
    let stat: String
}

// MARK: - Photos
public struct Photos: Codable {
    let page, pages, perpage: Int
    let total: String
    let photo: [Photo]
}

// MARK: - Photo
public struct Photo: Codable {
    let id, owner, secret, server: String
    let farm: Int
    let title: String
    let ispublic, isfriend, isfamily: Int
}
