//
//  Extension.swift
//  ImagePreview
//
//  Created by Max on 23.03.2021.
//

import Foundation
import UIKit

extension FileManager {
   static func documentsDirectory() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
}

extension UIImage {
    //Save to documents and return given name
    func saveToDocuments() -> String? {
        guard let data = self.jpegData(compressionQuality: 0.9) else {
            return nil
        }
        
        guard let documentsPath = FileManager.documentsDirectory() else {
            print("No documents directory")
            return nil
        }
        
        let imageName = "\(Date().hashValue).jpg"
        let filePath = documentsPath.appendingPathComponent(imageName)
        
        do {
            try data.write(to: filePath)
        } catch let error as NSError {
            print("Unable to save image \(error.localizedDescription)")
            return nil
        }
        return imageName
    }
    
    static func loadFromDocumentsDir(with name: String?) -> UIImage? {
        guard let imageName = name,
              let documentsDir = FileManager.documentsDirectory() else {
            return nil
        }
        
        let fullPath = documentsDir.appendingPathComponent(imageName)
              
        guard let data = try? Data(contentsOf: fullPath),
              let image = UIImage(data: data) else {
            print("No image")
            return nil
        }
        
        return image
    }
}
