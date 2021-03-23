//
//  SearchResult.swift
//  ImagePreview
//
//  Created by Max on 23.03.2021.
//

import Foundation
import UIKit
import RealmSwift


class SearchResult: Object {
    @objc dynamic var searchQuery = "nil"
    @objc dynamic var imagePath: String?
    
    override class func indexedProperties() -> [String] {
        return ["searchQuery","imageData"]
    }
}
