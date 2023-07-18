//
//  DetailViewModel.swift
//  PokemonPokedex
//
//  Created by Dimas Wisodewo on 18/07/23.
//

import Foundation

class DetailViewModel {
    
    private let pokemonColorName: String
    var getPokemonColorName: String {
        get {
            return pokemonColorName
        }
    }
    
    private let pokemonDetailModel: PokemonDetailModel
    var getPokemonDetailModel: PokemonDetailModel {
        get {
            return pokemonDetailModel
        }
    }
    
    private var encodedImage: String?
    
    var getPokemonFormattedId: String {
        get {
            let idString = String(pokemonDetailModel.id)
            var editedString = "#"
            for _ in 0..<(4-idString.count) {
                editedString.append("0")
            }
            editedString.append(idString)
            return editedString
        }
    }
    
    init(pokemonDetailModel: PokemonDetailModel, pokemonColorName: String) {
        self.pokemonColorName = pokemonColorName
        self.pokemonDetailModel = pokemonDetailModel
    }
    
    func setEncodedImage(base64Image: String) {
        encodedImage = base64Image
    }
    
    func setupFavoriteButton(completion: @escaping ((Bool) -> Void)) {
        DataPersistenceManager.shared.isPokemonExistsInDatabase(with: pokemonDetailModel.name) { result in
            switch result {
            case .success(let isExists):
                completion(isExists)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // Save to Core Data
    func saveToCoreData(completion: @escaping ((Bool) -> Void)) {
        
        var model: PokemonEntityModel?
        do {
            guard let encodedImage = encodedImage else {
                print("encodedImage is nil")
                throw DatabaseError.failedToConvert
            }
            
            model = try DataPersistenceManager.shared.convertToPokemonEntityModel(
                pokemonDetailModel: pokemonDetailModel,
                pokemonColorName: pokemonColorName,
                pokemonImageBase64: encodedImage)
        } catch {
            print(error)
        }
        
        guard let unwrappedModel = model else { return }
        DataPersistenceManager.shared.addPokemonData(with: unwrappedModel) { [weak self] result in
            switch result {
            case .success():
                print("Saved to Core Data: \(unwrappedModel.name)")
                self?.encodedImage = nil
                completion(true)
            case .failure(let error):
                print("Failed to save to Core Data: \(unwrappedModel.name), error message: \(error)")
                completion(false)
            }
        }
    }
    
    // Delete from Core Data
    func deleteFromCoreData(completion: @escaping ((Bool) -> Void)) {
        DataPersistenceManager.shared.deletePokemonData(with: pokemonDetailModel.name) { [weak self] result in
            guard let unwrappedSelf = self else { return }
            switch result {
            case .success():
                print("Deleted from Core Data: \(unwrappedSelf.pokemonDetailModel.name)")
                completion(true)
            case .failure(let error):
                print("Failed to delete from Core Data: \(unwrappedSelf.pokemonDetailModel.name), error message: \(error)")
                completion(false)
            }
        }
    }
}
