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
    var networkManager: NetworkServiceProtocol!
    
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
    var constraintsIsSet = false
    
    init(networkManager: NetworkServiceProtocol) {
        super.init(nibName: nil, bundle: nil)
        
        self.networkManager = networkManager
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
    
    private func configureViews() {
        configureTableView()
        configureSearchController()
        
        view.setNeedsLayout()
    }
    
    private func configureTableView() {
        tableView.dataSource = self
//        tableView.delegate = self
        tableView.register(SearchResultCell.self,
                           forCellReuseIdentifier: String(describing: SearchResultCell.self))
        tableView.rowHeight = 80
        view.addSubview(tableView)
    }
    
    private func configureSearchController() {
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchResultsUpdater = self
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
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SearchResultCell.self)) as? SearchResultCell else {
            fatalError("No cell with given identifier")
        }
        
        cell.textLabel?.text = String(indexPath.row)
        cell.setImage(to: UIImage(named: "placehold"))
        return cell
    }
}

extension PhotoSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchQuery = searchController.searchBar.text else {
            return
        }
        guard searchQuery.count == 4 else {
            return
        }
        
        print(searchController.searchBar.text as Any)
        networkManager.requestPhoto(with: searchQuery)
        
    }
    
}


