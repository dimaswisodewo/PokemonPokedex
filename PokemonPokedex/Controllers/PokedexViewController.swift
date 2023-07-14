//
//  ViewController.swift
//  PokemonPokedex
//
//  Created by Dimas Wisodewo on 11/07/23.
//

import UIKit

class PokedexViewController: UIViewController {

    @IBOutlet weak var pokedexCollectionView: UICollectionView! {
        didSet {
            pokedexCollectionView.largeContentTitle = "Pokedex"
            pokedexCollectionView.delegate = self
            pokedexCollectionView.dataSource = self
            pokedexCollectionView.register(
                UINib(nibName: PokedexCollectionViewCell.identifier, bundle: nil),
                forCellWithReuseIdentifier: PokedexCollectionViewCell.identifier)
        }
    }
    
    private var loadedData: [PokemonModel] = [PokemonModel]()
    private var loadedDataDetails: [PokemonDetailModel] = [PokemonDetailModel]()
    private var loadedDataSpecies: [PokemonSpeciesDetail] = [PokemonSpeciesDetail]()
    
    // Temporary array to store all data before all requests are completed (will be deleted if failed)
    private var loadedDataTemporary: [PokemonModel] = [PokemonModel]()
    private var loadedDataDetailsTemporary: [PokemonDetailModel] = [PokemonDetailModel]()
    private var loadedDataSpeciesTemporary: [PokemonSpeciesDetail] = [PokemonSpeciesDetail]()
    
    private var isDataDetailsUpdated = false
    private var isDataSpeciesUpdated = false
    
    private var isUpdating = false
    
    private let limit: Int = 20
    private var offset: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load from API
        loadPokemons()
        
        // Add observer when all data are done fetched
        let notificationName = Notification.Name("Done")
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadCollectionView),
            name: notificationName,
            object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Show tab bar
        tabBarController?.tabBar.isHidden = false
        
        // Handle when user starting the app offline
        if loadedData.isEmpty, !isUpdating {
            loadPokemons()
        }
    }
    
    private func loadPokemons() {
        let path = "pokemon"
        let query = offset == 0 ? "limit=\(limit)" : "limit=\(limit)&offset=\(offset)"
        var endpoint = Endpoint()
        endpoint.initialize(path: path, query: query)
        
        print("Load Pokemons, Limit: \(limit), Offset: \(offset)")
        
        loadedDataTemporary.removeAll()
        isUpdating = true
        NetworkManager.shared.sendRequest(type: PokemonResponse.self, endpoint: endpoint) { [weak self] result in
            switch result {
            case .success(let models):
                self?.loadedDataTemporary.append(contentsOf: models.results)
                self?.loadPokemonDetails() // Load images
                self?.loadPokemonSpecies() // Load background colors
            case .failure(let error):
                self?.isUpdating = false
                print(error)
            }
        }
    }
    
    private func loadPokemonDetails() {
        loadedDataDetailsTemporary.removeAll()
        for pokemonIndex in 0..<loadedDataTemporary.count {
            let path = "pokemon/\(loadedDataTemporary[pokemonIndex].name)/"
            var endpoint = Endpoint()
            endpoint.initialize(path: path, query: nil)
            
            NetworkManager.shared.sendRequest(type: PokemonDetailModel.self, endpoint: endpoint) { [weak self] result in
                switch result {
                case .success(let model):
                    self?.loadedDataDetailsTemporary.append(model)
                    self?.notificationCenterEmitter()
                case .failure(let error):
                    self?.isUpdating = false
                    print(error)
                }
            }
        }
    }
    
    private func loadPokemonSpecies() {
        loadedDataSpeciesTemporary.removeAll()
        for pokemonIndex in 0..<loadedDataTemporary.count {
            let path = "pokemon-species/\(loadedDataTemporary[pokemonIndex].name)/"
            var endpoint = Endpoint()
            endpoint.initialize(path: path, query: nil)
            
            NetworkManager.shared.sendRequest(type: PokemonSpeciesDetail.self, endpoint: endpoint) { [weak self] result in
                switch result {
                case .success(let model):
                    self?.loadedDataSpeciesTemporary.append(model)
                    self?.notificationCenterEmitter()
                case .failure(let error):
                    self?.isUpdating = false
                    print(error)
                }
            }
        }
    }
    
    @objc private func reloadCollectionView() {
        DispatchQueue.main.async { [weak self] in
            self?.pokedexCollectionView.reloadData()
        }
    }
    
    // Emit notif to reload data when all data is loaded
    private func notificationCenterEmitter() {
        
        isDataDetailsUpdated = loadedDataDetailsTemporary.count == loadedDataTemporary.count
        isDataSpeciesUpdated = loadedDataSpeciesTemporary.count == loadedDataTemporary.count
        
        if loadedDataTemporary.count > 0, loadedDataDetailsTemporary.count > 0, loadedDataSpeciesTemporary.count > 0,
           isDataDetailsUpdated, isDataSpeciesUpdated {
            
            // Sort
            loadedDataDetailsTemporary = loadedDataDetailsTemporary.sorted { $0.id < $1.id }
            loadedDataSpeciesTemporary = loadedDataSpeciesTemporary.sorted { $0.id < $1.id }
            
            loadedData.append(contentsOf: loadedDataTemporary)
            loadedDataDetails.append(contentsOf: loadedDataDetailsTemporary)
            loadedDataSpecies.append(contentsOf: loadedDataSpeciesTemporary)
            
            loadedDataTemporary.removeAll()
            loadedDataDetailsTemporary.removeAll()
            loadedDataSpeciesTemporary.removeAll()
            
            isUpdating = false
            offset += limit
            
            print("Done load all")
            let notificationName = Notification.Name("Done")
            NotificationCenter.default.post(name: notificationName, object: nil)
        }
    }
}

extension PokedexViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        loadedData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = pokedexCollectionView.dequeueReusableCell(
            withReuseIdentifier: PokedexCollectionViewCell.identifier,
            for: indexPath) as? PokedexCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: loadedData[indexPath.row])
        
        let idString = String(loadedDataDetails[indexPath.row].id)
        cell.configureId(with: idString)
        
        if isDataSpeciesUpdated {
            cell.configureColor(with: loadedDataSpecies[indexPath.row])
        }
        
        if isDataDetailsUpdated {
            cell.configureImage(with: loadedDataDetails[indexPath.row].sprites.frontDefault)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let vc = storyboard?.instantiateViewController(withIdentifier: DetailViewController.identifier) as? DetailViewController else { return }
        
        let model = loadedDataDetails[indexPath.row]
        let colorName = loadedDataSpecies[indexPath.row].color.name
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? PokedexCollectionViewCell else { return }
        guard let image = cell.imageView.image else { return }
        
        vc.configure(
            model: model,
            pokemonImage: image,
            pokemonColorName: colorName,
            pokemonColor: UIColor.getPredefinedColor(name: colorName)
        )
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let numOfColum = CGFloat(2)
        let collectionViewFlowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let spacing = (collectionViewFlowLayout.minimumInteritemSpacing * CGFloat(numOfColum - 1)) + collectionViewFlowLayout.sectionInset.left + collectionViewFlowLayout.sectionInset.right
        let width = (collectionView.frame.size.width / numOfColum ) - spacing
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 32
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if (indexPath.item == (offset - 1)) && !isUpdating {
            // Update data
            loadPokemons()
        }
    }

}
