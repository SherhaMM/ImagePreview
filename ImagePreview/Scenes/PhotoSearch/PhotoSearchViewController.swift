//
//  ViewController.swift
//  ImagePreview
//
//  Created by Max on 22.03.2021.
//

import UIKit
import Realm

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
    var searchResult = [SearchResult]() {
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
}

//MARK: UITableViewDataSource
extension PhotoSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SearchResultCell.self)) as? SearchResultCell else {
            fatalError("No cell with given identifier")
        }
        let row = indexPath.row
        cell.textLabel?.text = searchResult[row].searchQuery
        cell.setImage(to: searchResult[row].image)
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
        
        let searchEndpoint = Endpoint.searchPhotosByQuery(query: searchQuery,
                                                 countPerPage: "1",
                                                 pageNumber: "1")
        networkService.makeCodableRequest(endpoint:searchEndpoint) { (result: Result<PhotosSearchResult,Error>) in
            switch result {
            case .success(let data):
                let findedPhoto = data.photos.photo.first!
                self.downloadPhoto(with: findedPhoto) { image in
                    guard let image = image else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.searchResult.append(SearchResult(searchQuery: searchQuery, image: image))
                    }
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func downloadPhoto(with photo: Photo, completition: @escaping (UIImage?) -> Void) {
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
}


