//
//  DownloadViewController.swift
//  PokemonPokedex
//
//  Created by Dimas Wisodewo on 14/07/23.
//

import UIKit

class DownloadViewController: UIViewController {
    
    @IBOutlet weak var downloadedTableView: UITableView! {
        didSet {
            downloadedTableView.delegate = self
            downloadedTableView.dataSource = self
        }
    }
    
    private var downloadedPokemon = [PokemonEntity]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(DataPersistenceManager.shared.getDatabaseFileLocation())
        
        loadDownloadedPokemon()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if DataPersistenceManager.shared.isNeedToRefresh() {
            print("Refresh downloaded pokemon")
            loadDownloadedPokemon()
        }
    }
    
    // Fetch from Core Data
    private func loadDownloadedPokemon() {
        DataPersistenceManager.shared.fetchPokemonData { [weak self] result in
            switch result {
            case .success(let entities):
                guard let unwrappedSelf = self else { return }
                unwrappedSelf.downloadedPokemon = entities
                DispatchQueue.main.async {
                    unwrappedSelf.downloadedTableView.reloadData()
                    print("Downloaded pokemon count: \(unwrappedSelf.downloadedPokemon.count)")
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension DownloadViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        downloadedPokemon.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        
        var contentConfig = cell.defaultContentConfiguration()
        contentConfig.text = downloadedPokemon[indexPath.row].name
        
        cell.contentConfiguration = contentConfig
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
    
}
