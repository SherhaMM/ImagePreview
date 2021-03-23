//
//  FlickrResponseModel.swift
//  ImagePreview
//
//  Created by Max on 23.03.2021.
//

import Foundation

// MARK: - SearchResponse
struct SearchResponse: Codable {
    let pagedPhotosInfo: PagedPhotosInfo
    let stats: String

    enum CodingKeys: String, CodingKey {
        case pagedPhotosInfo = "photos"
        case stats = "stat"
    }
}
