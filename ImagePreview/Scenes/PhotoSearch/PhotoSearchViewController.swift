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
        tableView.allowsMultipleSelection = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    let searchController = UISearchController()
    
    //MARK: Variables
    var searchResults: Results<SearchResult>?
    
    var notificationToken: NotificationToken? = nil
    
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
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = .systemGray
        navigationController?.navigationBar.prefersLargeTitles = false
        
        tableView.contentOffset = CGPoint(x: 0, y: -searchController.searchBar.frame.height)
        
        observeSearchResultNotifications()
    }
    
    //MARK: Methods
    private func configureViews() {
        configureTableView()
        configureSearchController()
        
        view.setNeedsLayout()
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SearchResultCell.self,
                           forCellReuseIdentifier: String(describing: SearchResultCell.self))
        tableView.rowHeight = 150
        view.addSubview(tableView)
    }
    
    private func configureSearchController() {
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
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
    
    private func observeSearchResultNotifications() {
        guard let realm = try? Realm() else {
            print("Error while open realm")
            return
        }
        
        self.searchResults = realm.objects(SearchResult.self)
        
        notificationToken = searchResults?.observe({ [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let updates):
                tableView.beginUpdates()
                tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) },
                                     with: .automatic)
                tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) },
                                     with: .automatic)
                tableView.reloadRows(at: updates.map { IndexPath(row: $0, section: 0) },
                                     with: .automatic)
                tableView.endUpdates()
                
                self?.scrollToTheLastRow()
            case .error(let error):
                print("Error occured while updating tableView \(error.localizedDescription)")
            }
        })
    }
    
    private func scrollToTheLastRow() {
        let lastRow = tableView.numberOfRows(inSection: 0) - 1
        tableView.scrollToRow(at: IndexPath(row: lastRow, section: 0),
                              at: .bottom, animated: true)
    }
    
    private func presentAlert(with text: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: text,
                                                    message: "",
                                                    preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancel)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    deinit {
        notificationToken?.invalidate()
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
        cell.configure(with: result?.searchQuery, imageName: result?.imagePath)
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
        
        searchController.isActive = false
        
        searchAndRetrievePhoto(with: searchQuery)
        
        print(searchController.searchBar.text as Any)
    }
}

//MARK: Networking methods
extension PhotoSearchViewController {
    func searchAndRetrievePhoto(with textQuery: String) {
        DispatchQueue.global().async {
            // No PromiseKit ¯\_(ツ)_/¯
            self.searchPhotos(with: textQuery) { [weak self] (photoInfo) in
                guard let photoInfo = photoInfo else {
                    self?.presentAlert(with: "No photo was found with query \(textQuery)")
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
    
    func searchPhotos(with textQuery: String, completition: @escaping (PhotoInfo?) -> Void) {
        let searchEndpoint = Endpoint.searchPhotosByQuery(query: textQuery,
                                                 countPerPage: "1",
                                                 pageNumber: "1")
        
        networkService.makeCodableRequest(endpoint:searchEndpoint) { (result: Result<SearchResponse,Error>) in
            switch result {
            case .success(let data):
                let photoInfo = data.pagedPhotosInfo.photoInfos.first
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
        guard let savedImageName = image.saveToDocuments() else {
            print("Error while saving image")
            return
        }
        
        guard let realm = try? Realm() else {
            return
        }
        
        try? realm.write {
            let searchResult = SearchResult()
            searchResult.imagePath = savedImageName
            searchResult.searchQuery = textQuery
            realm.add(searchResult)
        }
    }
}


