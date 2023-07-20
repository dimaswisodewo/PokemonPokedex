//
//  DownloadViewModel.swift
//  PokemonPokedex
//
//  Created by Dimas Wisodewo on 19/07/23.
//

import Foundation

class DownloadViewModel {
    
    private var downloadedPokemon = [PokemonEntity]()
    var getDownloadedPokemonCount: Int {
        get {
            return downloadedPokemon.count
        }
    }
    
    var getDatabaseFileLocation: [URL] {
        get {
            return DataPersistenceManager.shared.getDatabaseFileLocation()
        }
    }
    
    var reloadTable: (() -> Void)?
    var deleteTableRowsAt: (([IndexPath]) -> Void)?
    
    func refreshTableViewIfNeeded() {
        if DataPersistenceManager.shared.isNeedToRefresh() {
            print("Refresh downloaded pokemon")
            loadDownloadedPokemon()
        }
    }
    
    func getDownloadedPokemonOnIndex(index: Int) -> PokemonEntity? {
        if index >= downloadedPokemon.count {
            return nil
        }
        return downloadedPokemon[index]
    }
    
    // Fetch from Core Data
    func loadDownloadedPokemon() {
        DataPersistenceManager.shared.fetchPokemonData { [weak self] result in
            switch result {
            case .success(let entities):
                guard let unwrappedSelf = self else { return }
                unwrappedSelf.downloadedPokemon = entities
                if let unwrappedReloadTable = unwrappedSelf.reloadTable {
                    DispatchQueue.main.async {
                        unwrappedReloadTable()
                        print("Downloaded pokemon count: \(unwrappedSelf.downloadedPokemon.count)")
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func deleteDownloadedPokemonByName(name: String, indexPath: IndexPath) {
        DataPersistenceManager.shared.deletePokemonData(with: name) { result in
            switch result {
            case .success():
                print("Deleted \(name)")
                DispatchQueue.main.async { [weak self] in
                    guard let deleteTableRowsAt = self?.deleteTableRowsAt else { return }
                    self?.downloadedPokemon.remove(at: indexPath.row)
                    deleteTableRowsAt([indexPath]) // Delete rows from table view
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func updateDownloadedPokemonName(oldName: String, newName: String) {
        DataPersistenceManager.shared.updatePokemonName(
            oldName: oldName,
            newName: newName) { [weak self] result in
                switch result {
                case .success():
                    print("Updated \(oldName) into \(newName)")
                    guard let unwrappedSelf = self else { return }
                    if let unwrappedReloadTable = unwrappedSelf.reloadTable {
                        DispatchQueue.main.async {
                            unwrappedReloadTable()
                        }
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    /// Return an `Optional Tuple` containing:
    /// 1: Pokemon detail model as `PokemonDetailModel`
    /// 2: Pokemon color name as `String`
    /// 3: Pokemon base64 encoded image as `String`
    /// Used to convert fetched data from Core Data so that it can be displayed in `DetailViewController`
    func getUnpackedEntityOnIndex(index: Int) -> (PokemonDetailModel, String, String)? {
        let entity = downloadedPokemon[index]
        var unpackedEntity: (PokemonDetailModel, String, String)?
        do {
            unpackedEntity = try DataPersistenceManager.shared.unpackFromPokemonEntity(pokemonEntity: entity)
        } catch {
            print(error)
        }
        return unpackedEntity
    }
    
    /// Convert into `PokemonEntityModel` to be saved into Core Data
    func convertToPokemonEntityModel(
        detailModel: PokemonDetailModel,
        colorName: String,
        encodedImage: String) -> PokemonEntityModel? {
            var entityModel: PokemonEntityModel?
            do {
                entityModel = try DataPersistenceManager.shared.convertToPokemonEntityModel(
                    pokemonDetailModel: detailModel,
                    pokemonColorName: colorName,
                    encodedImage: encodedImage)
            } catch {
                print(error)
            }
            
            return entityModel
    }
}
