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

class StargazersListController: UITableViewController, DataManagerDelegate {
    
    let dataManager = DataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataManager.delegate = self
        
        openSearchController()
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "id_cell_stargazers_table", for: indexPath) as! TableCellController
        let data = dataManager.stargazers[indexPath.row]
        cell.picture.image = data.avatar        
        cell.title.text = data.username
        return cell
    }
    
    
    //MARK:- DataManager
    
    func stargazersDataReady(stargazers: [User]) {
        navigationItem.setTitle(UserDefaults.standard.string(forKey: "owner")!, subtitle: UserDefaults.standard.string(forKey: "repository")!)
        tableView.reloadData()
    }
    
    func stargazersDataNotAvailable(error: String) {
        simpleAlert(text: error)
    }
    
    
    //MARK:- Private functions
    
    private func openSearchController() {
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "id_storyboard_search") as? SearchViewController {
            viewController.modalPresentationStyle = .overFullScreen
            viewController.dataManager = dataManager
            present(viewController, animated: true, completion: nil)
        }
    }
    
}

