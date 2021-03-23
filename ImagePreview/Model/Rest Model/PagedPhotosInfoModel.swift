//
//  PhotosModel.swift
//  ImagePreview
//
//  Created by Max on 23.03.2021.
//

import Foundation

// MARK: - PagedPhotosInfo
struct PagedPhotosInfo: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photoInfos: [PhotoInfo]

    enum CodingKeys: String, CodingKey {
        case page = "page"
        case pages = "pages"
        case perpage = "perpage"
        case total = "total"
        case photoInfos = "photo"
    }
}
