//
//  ViewController.swift
//  Stargazers
//
//  Created by Marco Ricca on 02/12/2020
//
//  Created for Stargazers in 02/12/2020
//  Using Swift 5.0
//  Running on macOS 10.15
//
//  
//


import UIKit
import SwifterSwift

class StargazersTableViewController: UITableViewController, UITableViewDataSourcePrefetching, DataManagerDelegate {
    
    let dataManager = DataManager()
    var page = 1
    var isLoading = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.prefetchDataSource = self
        dataManager.delegate = self
        
        addPullToRefresh()
        openSearchViewController(self)
    }
    
    
    //MARK: - TableView
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataManager.stargazers.count
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            let cell = tableView.dequeueReusableCell(withIdentifier: "id_cell_stargazers_table", for: $0) as! TableCellController
            fetchUserAvatar(cell, $0)
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            let cell = tableView.dequeueReusableCell(withIdentifier: "id_cell_stargazers_table", for: $0) as! TableCellController
            cell.dataRequest?.cancel()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "id_cell_stargazers_table", for: indexPath) as! TableCellController
        let dataM = dataManager.stargazers[indexPath.row]
        cell.title.text = dataM.username
        fetchUserAvatar(cell, indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !isLoading && indexPath.row == tableView.numberOfRows() - 1 {
            page = page + 1
            isLoading = true
            dataManager.getStargazers(UserDefaults.standard.string(forKey: "owner") ?? "", UserDefaults.standard.string(forKey: "repository") ?? "", page)
        }
    }
    
    
    //MARK:- DataManager
    
    func stargazersDataReady(stargazers: [User]) {
        isLoading = false
        if page != 1 {
            delay(1.0) {
                self.reloadTable()
            }
        } else {
            reloadTable()
        }
    }
    
    func stargazersDataNotAvailable(error: String) {
        isLoading = false
        reloadTable()
        simpleAlert(title: loc("ERROR"), text: loc(error)) { [self] _ in
            openSearchViewController(self)
        }
    }
    
    
    //MARK:- Private functions
    
    private func addPullToRefresh(){
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:  #selector(refreshInfo), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func reloadTable(){
        navigationItem.setTitle(UserDefaults.standard.string(forKey: "owner")!, subtitle: UserDefaults.standard.string(forKey: "repository")!)
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    @objc private func refreshInfo() {
        page = 1
        isLoading = true
        dataManager.getStargazers(UserDefaults.standard.string(forKey: "owner") ?? "", UserDefaults.standard.string(forKey: "repository") ?? "", page)
    }
    
    private func fetchUserAvatar(_ cell: TableCellController, _ indexPath: IndexPath){
        if let url = URL(string: dataManager.stargazers[indexPath.row].avatarUrl), dataManager.stargazers[indexPath.row].avatar == UIImage(systemName: "person.crop.circle.fill")! {
            cell.dataRequest = AFManager.request(url, method: .get).responseData { (response) in
                if response.error == nil, let data = response.data, let img = UIImage(data: data) {
                    if response.request?.url?.absoluteString == cell.dataRequest?.request!.url?.absoluteString {
                        cell.picture.image = img
                        self.dataManager.stargazers[indexPath.row].avatar = img
                    }
                }
            }
        } else {
            cell.picture.image = dataManager.stargazers[indexPath.row].avatar
        }
    }
    
    
    //MARK:- IBActions
    
    @IBAction func openSearchViewController(_ sender: Any) {
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "id_storyboard_search") as? SearchViewController {
            viewController.modalPresentationStyle = .overFullScreen
            viewController.dataManager = dataManager
            present(viewController, animated: true, completion: nil)
        }
    }
    
}
