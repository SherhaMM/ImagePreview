//
//  ViewController.swift
//  ImagePreview
//
//  Created by Max on 22.03.2021.
//

import UIKit
import RealmSwift

final class PhotoSearchViewController: UIViewController {
    
    //MARK: Dependencies
    var networkService: NetworkServiceProtocol!
    
    //MARK: UI Elements
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.allowsMultipleSelection = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    let searchController = UISearchController()
    
    //MARK: Variables
    
    var searchResults: Results<SearchResult>? {
        didSet {
            tableView.reloadData()
        }
    }
    
    var constraintsIsSet = false
    
    init(networkService: NetworkServiceProtocol) {
        super.init(nibName: nil, bundle: nil)
        
        self.networkService = networkService
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        title = "Search some image!"
        view.backgroundColor = .white
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.tintColor = .black
    }
    
    //MARK: Methods
    private func configureViews() {
        configureTableView()
        configureSearchController()
        
        view.setNeedsLayout()
        
        fetchResults()
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SearchResultCell.self,
                           forCellReuseIdentifier: String(describing: SearchResultCell.self))
        tableView.rowHeight = 80
        view.addSubview(tableView)
    }
    
    private func configureSearchController() {
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        guard !constraintsIsSet else {
            return
        }
        
        layoutViews()
        
        constraintsIsSet = true
    }
    
    private func layoutViews() {
        NSLayoutConstraint.activate([
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func fetchResults() {
        guard let realm = try? Realm() else {
            print("Couldnt init realm")
            return
        }
        
        let results = realm.objects(SearchResult.self)
        self.searchResults = results
    }
}

//MARK: UITableViewDataSource
extension PhotoSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SearchResultCell.self)) as? SearchResultCell else {
            fatalError("No cell with given identifier")
        }
        
        let result = searchResults?[indexPath.row]
        cell.configure(with: result?.searchQuery, imagePath: result?.imagePath)
        return cell
    }
}

//MARK: UITableViewDelegate
extension PhotoSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

//MARK: UISearchResultsUpdating
extension PhotoSearchViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchQuery = searchBar.text else {
            return
        }
        
        print(searchController.searchBar.text as Any)
        
        searchAndRetrievePhoto(with: searchQuery)
    }
}

//MARK: Networking
extension PhotoSearchViewController {
    func searchAndRetrievePhoto(with textQuery: String) {
        DispatchQueue.global().async {
            self.searchPhotos(with: textQuery) { [weak self] (photoInfo) in
                guard let photoInfo = photoInfo else {
                    print("No info about photo was given")
                    return
                }
                
                self?.downloadImage(with: photoInfo) { (image) in
                    guard let image = image else {
                        print("No image returned")
                        return
                    }
                    
                    self?.saveImage(image: image, textQuery: textQuery)
                }
            }
        }
    }
    
    func searchPhotos(with textQuery: String,completition: @escaping (PhotoInfo?) -> Void) {
        let searchEndpoint = Endpoint.searchPhotosByQuery(query: textQuery,
                                                 countPerPage: "1",
                                                 pageNumber: "1")
        
        networkService.makeCodableRequest(endpoint:searchEndpoint) { (result: Result<PhotosSearchResult,Error>) in
            switch result {
            case .success(let data):
                let photoInfo = data.photos.photo.first!
                completition(photoInfo)
            case .failure(let error):
                completition(nil)
                print(error)
            }
        }
    }
    
    func downloadImage(with photo: PhotoInfo, completition: @escaping (UIImage?) -> Void) {
        let getPhotoEndpoint = Endpoint.getPhoto(serverId: photo.server,
                                                 id: photo.id,
                                                 secret: photo.secret)
        networkService.makeDataRequest(endpoint: getPhotoEndpoint) { (result) in
            switch result {
            case .success(let data):
                guard let image = UIImage(data: data) else {
                    return
                }
                completition(image)
            case .failure(let error):
                print("Error while downloading photo \(error.localizedDescription)")
                completition(nil)
            }
        }
    }
    
    func saveImage(image: UIImage, textQuery: String) {
        guard let data = image.jpegData(compressionQuality: 0.9) else {
            return
        }
        
        guard let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("No documentsPath found")
            return
        }
        
        let fileName = filePath.appendingPathComponent("\(Date().hashValue).jpg")
        
        do {
            try data.write(to: fileName)
        } catch let error as NSError {
            print("Unable to save image \(error.localizedDescription)")
            return
        }
        
        guard let realm = try? Realm() else {
            return
        }
        
        try? realm.write {
            let searchResult = SearchResult()
            searchResult.imagePath = fileName.absoluteString
            searchResult.searchQuery = textQuery
            realm.add(searchResult)
        }
    }
}


