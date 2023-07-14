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
    
    private var isDataDetailsUpdated = false
    private var isDataSpeciesUpdated = false
    
    private var isAllDataDisplayed = false
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
    }
    
    private func loadPokemons() {
        let path = "pokemon"
        let query = offset == 0 ? "limit=\(limit)" : "limit=\(limit)&offset=\(offset)"
        var endpoint = Endpoint()
        endpoint.initialize(path: path, query: query)
        
        print("Load Pokemons, Limit: \(limit), Offset: \(offset)")
        
        isAllDataDisplayed = false
        isUpdating = true
        NetworkManager.shared.sendRequest(type: PokemonResponse.self, endpoint: endpoint) { [weak self] result in
            switch result {
            case .success(let models):
                self?.loadedData.append(contentsOf: models.results)
                self?.loadPokemonDetails() // Load images
                self?.loadPokemonSpecies() // Load background colors
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func loadPokemonDetails() {
        for pokemonIndex in offset..<loadedData.count {
            let path = "pokemon/\(loadedData[pokemonIndex].name)/"
            var endpoint = Endpoint()
            endpoint.initialize(path: path, query: nil)
            
            NetworkManager.shared.sendRequest(type: PokemonDetailModel.self, endpoint: endpoint) { [weak self] result in
                switch result {
                case .success(let model):
                    self?.loadedDataDetails.append(model)
                    self?.notificationCenterEmitter()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    private func loadPokemonSpecies() {
        for pokemonIndex in offset..<loadedData.count {
            let path = "pokemon-species/\(loadedData[pokemonIndex].name)/"
            var endpoint = Endpoint()
            endpoint.initialize(path: path, query: nil)
            
            NetworkManager.shared.sendRequest(type: PokemonSpeciesDetail.self, endpoint: endpoint) { [weak self] result in
                switch result {
                case .success(let model):
                    self?.loadedDataSpecies.append(model)
                    self?.notificationCenterEmitter()
                case .failure(let error):
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
        
        isDataDetailsUpdated = loadedDataDetails.count == loadedData.count
        isDataSpeciesUpdated = loadedDataSpecies.count == loadedData.count
        
        if loadedData.count > 0, loadedDataDetails.count > 0, loadedDataSpecies.count > 0,
           isDataDetailsUpdated, isDataSpeciesUpdated {
            
            // Sort
            loadedDataDetails = loadedDataDetails.sorted { $0.id < $1.id }
            loadedDataSpecies = loadedDataSpecies.sorted { $0.id < $1.id }
            
            isAllDataDisplayed = true
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
        
        if (isAllDataDisplayed && indexPath.item == (offset - 1) && !isUpdating) {
            // Update data
            loadPokemons()
        }
    }

}
