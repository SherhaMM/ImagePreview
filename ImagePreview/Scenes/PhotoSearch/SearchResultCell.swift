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
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private var searchTermLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let edgesInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
   
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(searchImage)
        contentView.addSubview(searchTermLabel)
        
        contentView.setNeedsUpdateConstraints()
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        constraintViews()
    }
    
    private func constraintViews() {
        let imageSize = contentView.frame.height * 0.8
        
        NSLayoutConstraint.activate([
            searchTermLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 10),
            searchTermLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            searchImage.widthAnchor.constraint(equalToConstant: imageSize),
            searchImage.heightAnchor.constraint(equalToConstant: imageSize),
            searchImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant:  -10),
            searchImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
//            searchImage.topAnchor.constraint(equalTo: contentView.topAnchor),
//            searchImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    public func configure(with text: String?, imageName: String?) {
        searchTermLabel.text = text
        
        loadAndSetImage(from: imageName)
    }
    
    public func loadAndSetImage(from imageName: String?) {
        let image = UIImage.loadFromDocumentsDir(with: imageName)
        
        searchImage.image = image
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        searchTermLabel.text = ""
        searchImage.image = nil
    }
}
