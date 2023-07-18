//
//  PokedexViewModel.swift
//  PokemonPokedex
//
//  Created by Dimas Wisodewo on 18/07/23.
//

import Foundation

class PokedexViewModel {
    
    private var loadedData = [PokemonModel]()
    private var loadedDataDetails = [PokemonDetailModel]()
    private var loadedDataSpecies = [PokemonSpeciesDetail]()
    
    var reloadTableView: (() -> Void)?
    
    var getLoadedDataCount: Int {
        get {
            return loadedData.count
        }
    }
    
    var getLoadedDataDetailsCount: Int {
        get {
            return loadedDataDetails.count
        }
    }
    
    var getLoadedDataSpeciesCount: Int {
        get {
            return loadedDataSpecies.count
        }
    }
    
    // Temporary array to store all data before all requests are completed (will be deleted if failed)
    private var loadedDataTemp = [PokemonModel]()
    private var loadedDataDetailsTemp = [PokemonDetailModel]()
    private var loadedDataSpeciesTemp = [PokemonSpeciesDetail]()
    
    private var isDataDetailsUpdated = false
    var getIsDataDetailsUpdated: Bool {
        get {
            return isDataDetailsUpdated
        }
    }
    
    private var isDataSpeciesUpdated = false
    var getIsDataSpeciesUpdated: Bool {
        get {
            return isDataSpeciesUpdated
        }
    }
    
    private var isUpdating = false
    var getIsUpdating: Bool {
        get {
            return isUpdating
        }
    }
    
    private let limit: Int = 20
    private var offset: Int = 0
    var getOffset: Int {
        get {
            return offset
        }
    }
    
    func getLoadedData(onIndex index: Int) -> PokemonModel? {
        if index >= loadedData.count {
            print("index out of bounds")
            return nil
        }
        return loadedData[index]
    }
    
    func getLoadedDataDetails(onIndex index: Int) -> PokemonDetailModel? {
        if index >= loadedDataDetails.count {
            print("index out of bounds")
            return nil
        }
        return loadedDataDetails[index]
    }
    
    func getLoadedDataSpecies(onIndex index: Int) -> PokemonSpeciesDetail? {
        if index >= loadedDataSpecies.count {
            print("index out of bounds")
            return nil
        }
        return loadedDataSpecies[index]
    }
    
    func loadPokemons() {
        let path = "pokemon"
        let query = offset == 0 ? "limit=\(limit)" : "limit=\(limit)&offset=\(offset)"
        var endpoint = Endpoint()
        endpoint.initialize(path: path, query: query)
        
        print("Load Pokemons, Limit: \(limit), Offset: \(offset)")
        
        loadedDataTemp.removeAll()
        isUpdating = true
        NetworkManager.shared.sendRequest(type: PokemonResponse.self, endpoint: endpoint) { [weak self] result in
            switch result {
            case .success(let models):
                self?.loadedDataTemp.append(contentsOf: models.results)
                self?.loadPokemonDetails() // Load images
                self?.loadPokemonSpecies() // Load background colors
            case .failure(let error):
                self?.isUpdating = false
                print(error)
            }
        }
    }
    
    func loadPokemonDetails() {
        loadedDataDetailsTemp.removeAll()
        for pokemonIndex in 0..<loadedDataTemp.count {
            let path = "pokemon/\(loadedDataTemp[pokemonIndex].name)/"
            var endpoint = Endpoint()
            endpoint.initialize(path: path, query: nil)
            
            NetworkManager.shared.sendRequest(type: PokemonDetailModel.self, endpoint: endpoint) { [weak self] result in
                switch result {
                case .success(let model):
                    self?.loadedDataDetailsTemp.append(model)
                    self?.notificationCenterEmitter()
                case .failure(let error):
                    self?.isUpdating = false
                    print(error)
                }
            }
        }
    }
    
    func loadPokemonSpecies() {
        loadedDataSpeciesTemp.removeAll()
        for pokemonIndex in 0..<loadedDataTemp.count {
            let path = "pokemon-species/\(loadedDataTemp[pokemonIndex].name)/"
            var endpoint = Endpoint()
            endpoint.initialize(path: path, query: nil)
            
            NetworkManager.shared.sendRequest(type: PokemonSpeciesDetail.self, endpoint: endpoint) { [weak self] result in
                switch result {
                case .success(let model):
                    self?.loadedDataSpeciesTemp.append(model)
                    self?.notificationCenterEmitter()
                case .failure(let error):
                    self?.isUpdating = false
                    print(error)
                }
            }
        }
    }
    
    // Emit notif to reload data when all data is loaded
    private func notificationCenterEmitter() {
        
        isDataDetailsUpdated = loadedDataDetailsTemp.count == loadedDataTemp.count
        isDataSpeciesUpdated = loadedDataSpeciesTemp.count == loadedDataTemp.count
        
        if loadedDataTemp.count > 0,
           loadedDataDetailsTemp.count > 0,
           loadedDataSpeciesTemp.count > 0,
           isDataDetailsUpdated, isDataSpeciesUpdated {
            
            // Sort
            loadedDataDetailsTemp = loadedDataDetailsTemp.sorted { $0.id < $1.id }
            loadedDataSpeciesTemp = loadedDataSpeciesTemp.sorted { $0.id < $1.id }
            
            loadedData.append(contentsOf: loadedDataTemp)
            loadedDataDetails.append(contentsOf: loadedDataDetailsTemp)
            loadedDataSpecies.append(contentsOf: loadedDataSpeciesTemp)
            
            loadedDataTemp.removeAll()
            loadedDataDetailsTemp.removeAll()
            loadedDataSpeciesTemp.removeAll()
            
            isUpdating = false
            offset += limit
            
            print("Done load all")
            reloadTableView!()
        }
    }
}
