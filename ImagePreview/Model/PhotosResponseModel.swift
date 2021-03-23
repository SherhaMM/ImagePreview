//
//  FlickrResponseModel.swift
//  ImagePreview
//
//  Created by Max on 23.03.2021.
//

import Foundation

// MARK: - PhotosSearchResult
struct PhotosSearchResult: Codable {
    let photos: Photos
    let stat: String

    enum CodingKeys: String, CodingKey {
        case photos = "photos"
        case stat = "stat"
    }
}
