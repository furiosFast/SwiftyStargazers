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
    
    let ID_CELL_STARGAZERS_TABLE = "id_cell_stargazers_table"
    let ID_STORYBOARD_SEARCH = "id_storyboard_search"
    
    let dataManager = DataManager()
    var isLoadingNewStargazers = true
    var page = 1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.prefetchDataSource = self
        dataManager.delegate = self
        
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
            let cell = tableView.dequeueReusableCell(withIdentifier: ID_CELL_STARGAZERS_TABLE, for: $0) as! TableCellController
            fetchUserAvatar(cell, $0)
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            let cell = tableView.dequeueReusableCell(withIdentifier: ID_CELL_STARGAZERS_TABLE, for: $0) as! TableCellController
            cell.dataRequest?.cancel()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ID_CELL_STARGAZERS_TABLE, for: indexPath) as! TableCellController
        let dataM = dataManager.stargazers[indexPath.row]
        cell.title.text = dataM.username
        cell.picture.image = avatarPlaceholder
        fetchUserAvatar(cell, indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !isLoadingNewStargazers && indexPath.row == tableView.numberOfRows() - 1 {
            page = page + 1
            isLoadingNewStargazers = true
            dataManager.getStargazers(UserDefaults.standard.string(forKey: "owner") ?? "", UserDefaults.standard.string(forKey: "repository") ?? "", page)
        }
    }
    
    
    //MARK:- DataManager
    
    func stargazersDataReady(stargazers: [User]) {
        isLoadingNewStargazers = false
        if page != 1 {
            delay(1.0) {
                self.reloadTable()
            }
        } else {
            reloadTable()
        }
    }
    
    func stargazersDataNotAvailable(error: String) {
        isLoadingNewStargazers = false
        reloadTable()
        simpleAlert(title: loc("alert_WARNING"), text: loc(error)) { [self] _ in
            openSearchViewController(self)
        }
    }
    
    
    //MARK:- Private functions
    
    private func reloadTable(){
        navigationItem.setTitle(UserDefaults.standard.string(forKey: "owner")!, subtitle: UserDefaults.standard.string(forKey: "repository")!)
        tableView.reloadData()
    }
    
    @objc private func refreshInfo() {
        page = 1
        isLoadingNewStargazers = true
        dataManager.getStargazers(UserDefaults.standard.string(forKey: "owner") ?? "", UserDefaults.standard.string(forKey: "repository") ?? "", page)
    }
    
    private func fetchUserAvatar(_ cell: TableCellController, _ indexPath: IndexPath){
        if let url = URL(string: dataManager.stargazers[indexPath.row].avatarUrl), dataManager.stargazers[indexPath.row].avatar == avatarPlaceholder {
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
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: ID_STORYBOARD_SEARCH) as? SearchViewController {
            viewController.modalPresentationStyle = .overFullScreen
            viewController.dataManager = dataManager
            present(viewController, animated: true, completion: nil)
        }
    }
    
}
