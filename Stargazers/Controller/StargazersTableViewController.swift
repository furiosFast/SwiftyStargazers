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
import Kingfisher

class StargazersTableViewController: UITableViewController, DataManagerDelegate {
    
    let ID_CELL_STARGAZERS_TABLE = "id_cell_stargazers_table"
    
    let dataManager = DataManager()
    var isLoadingNewStargazers = true
    var page = 1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ID_CELL_STARGAZERS_TABLE, for: indexPath) as! TableCellController
        cell.title.text = dataManager.stargazers[indexPath.row].username
        cell.picture.layer.borderWidth = 2
        cell.picture.layer.borderColor = UIColor(named: "AccentColor")?.cgColor
        cell.picture.layer.cornerRadius = cell.picture.bounds.width / 2
        if let url = URL(string: dataManager.stargazers[indexPath.row].avatarUrl) {
            cell.picture.kf.setImage(with: url, placeholder: avatarPlaceholder)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !isLoadingNewStargazers && indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
            page = page + 1
            isLoadingNewStargazers = true
            dataManager.getStargazers(UserDefaults.standard.string(forKey: "owner") ?? "", UserDefaults.standard.string(forKey: "repository") ?? "", page)
        }
    }
    
    
    //MARK:- DataManager
    
    func stargazersDataReady(stargazers: [User]) {
        isLoadingNewStargazers = false
        delay(0.5) {
            self.reloadTable()
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

    
    //MARK:- IBActions
    
    @IBAction func openSearchViewController(_ sender: Any) {
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: ID_STORYBOARD_SEARCH) as? SearchViewController {
            viewController.modalPresentationStyle = .overFullScreen
            viewController.dataManager = dataManager
            present(viewController, animated: true, completion: nil)
        }
    }
    
}
