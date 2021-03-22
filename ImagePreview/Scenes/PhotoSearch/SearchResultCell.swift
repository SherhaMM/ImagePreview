//
//  PhotoSearchCell.swift
//  ImagePreview
//
//  Created by Max on 22.03.2021.
//

import Foundation
import UIKit

final class SearchResultCell: UITableViewCell {
    
    private var searchImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let edgesInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
   
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        layoutViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layoutViews() {
        contentView.addSubview(searchImage)
        
        NSLayoutConstraint.activate([
            searchImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant:  -10),
            searchImage.topAnchor.constraint(equalTo: contentView.topAnchor),
            searchImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    public func setImage(to image: UIImage?) {
        searchImage.image = image
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        searchImage.image = nil
    }
}
