//
//  SearchViewController.swift
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
class SearchViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var ownerTitle: UILabel!
    @IBOutlet var owner: UITextField!
    @IBOutlet var repositoryTitle: UILabel!
    @IBOutlet var repository: UITextField!
    @IBOutlet var searchButton: UIButton!
    
    var dataManager: DataManager?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        owner.delegate = self
        repository.delegate = self
        
        setLabelsText()
        owner.text = UserDefaults.standard.string(forKey: "owner")
        repository.text = UserDefaults.standard.string(forKey: "repository")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        owner.becomeFirstResponder()
    }
    
    
    // MARK: - TextField
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == owner {
            textField.resignFirstResponder()
            repository.becomeFirstResponder()
        }
        if textField == repository {
            repository.resignFirstResponder()
            searchStargazers(self)
        }
        return true
    }
    
    
    // MARK: - Private functions
    
    private func setLabelsText(){
        ownerTitle.text = loc("owner")
        repositoryTitle.text = loc("repo")
        owner.placeholder = loc("owner") + "..."
        repository.placeholder = loc("repo") + "..."
        searchButton.titleForNormal = loc("search")
    }
    
    
    //MARK:- IBActions
    
    @IBAction func searchStargazers(_ sender: Any){
        guard let usr = owner.text, let repo = repository.text, let dm = dataManager else { return }
        if usr.isEmpty {
            simpleAlert(text: loc("validationError_EMPTYOWNER"))
            return
        }
        if repo.isEmpty {
            simpleAlert(text: loc("validationError_EMPTYREPONAME"))
            return
        }
        
        dismiss(animated: true) {
            self.searchButton.isHidden = true
            self.searchButton.isUserInteractionEnabled = false
            savePreferenceLocal(usr, "owner")
            savePreferenceLocal(repo, "repository")
            dm.getStargazers(usr, repo, 1)
        }
    }
    
}
