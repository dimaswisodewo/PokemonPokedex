//
//  DataPersistenceManager.swift
//  PokemonPokedex
//
//  Created by Dimas Wisodewo on 14/07/23.
//

import UIKit
import CoreData

class DataPersistenceManager {
    
    enum DatabaseError: Error {
        case failedToAdd
        case failedToFetch
        case failedToUpdate
        case failedtoDelete
    }
    
    static let shared = DataPersistenceManager()
    
    private var isHasChanges = false
    
    func getDatabaseFileLocation() -> [URL]{
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    }
    
    func isNeedToRefresh() -> Bool {
        return isHasChanges
    }
    
    // Add pokemon
    func addPokemonData(with model: PokemonEntityModel, completion: @escaping (Result<Void, Error>) -> Void) {

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext

        let entity = PokemonEntity(context: context)
        entity.id = Int16(model.id)
        entity.name = model.name
        entity.image = model.image
        entity.abilities = model.abilities
        entity.types = model.types
        entity.moves = model.moves
        entity.weight = Int16(model.weight)
        entity.height = Int16(model.height)
        entity.hp = Int16(model.hp)
        entity.attack = Int16(model.attack)
        entity.defense = Int16(model.defense)
        entity.specialAttack = Int16(model.specialAttack)
        entity.specialDefense = Int16(model.specialDefense)
        entity.speed = Int16(model.speed)

        do {
            try context.save()
            isHasChanges = true
            completion(.success(()))
        } catch {
            completion(.failure(DatabaseError.failedToAdd))
        }
    }

    // Fetch all favorited pokemon
    func fetchPokemonData(completion: @escaping (Result<[PokemonEntity], Error>) -> Void) {

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext

        let request: NSFetchRequest<PokemonEntity>
        request = PokemonEntity.fetchRequest()

        do {
            let pokemonData = try context.fetch(request)
            isHasChanges = false
            completion(.success(pokemonData))
        } catch {
            completion(.failure(DatabaseError.failedToFetch))
        }
    }
    
    func isPokemonExistsInDatabase(with pokemonName: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext

        let predicate = NSPredicate(format: "name = %@", pokemonName)
        
        let request: NSFetchRequest<PokemonEntity>
        request = PokemonEntity.fetchRequest()
        request.predicate = predicate

        do {
            let pokemonData = try context.fetch(request)
            let isExists = pokemonData.count > 0
            completion(.success(isExists))
        } catch {
            completion(.failure(DatabaseError.failedToFetch))
        }
    }
    
    // Delete favorited pokemon
    func deletePokemonData(with pokemonName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        let predicate = NSPredicate(format: "name = %@", pokemonName)
        
        let request: NSFetchRequest<PokemonEntity>
        request = PokemonEntity.fetchRequest()
        request.predicate = predicate
        
        do {
            
            guard let entity = try context.fetch(request).first else {
                print("There is no favorited pokemon with name: \(pokemonName)")
                throw DatabaseError.failedToFetch
            }
            
            context.delete(entity)
            try context.save()
            isHasChanges = true
            completion(.success(()))
        } catch {
            completion(.failure(DatabaseError.failedtoDelete))
        }
    }

}
