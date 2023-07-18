//
//  DataPersistenceManager.swift
//  PokemonPokedex
//
//  Created by Dimas Wisodewo on 14/07/23.
//

import UIKit
import CoreData

enum DatabaseError: Error {
    case failedToAdd
    case failedToFetch
    case failedToUpdate
    case failedToDelete
    case failedToConvert
}

class DataPersistenceManager {
    
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
        entity.imageUrl = model.imageUrl
        entity.color = model.color
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
    
    // Update favorited pokemon name
    func updatePokemonName(oldName: String, newName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        let predicate = NSPredicate(format: "name = %@", oldName)
        
        let request: NSFetchRequest<PokemonEntity>
        request = PokemonEntity.fetchRequest()
        request.predicate = predicate
        
        do {
            
            guard let entity = try context.fetch(request).first else {
                print("There is no favorited pokemon with name: \(oldName)")
                throw DatabaseError.failedToFetch
            }
            
            entity.name = newName
            
            try context.save()
            isHasChanges = true
            completion(.success(()))
        } catch {
            completion(.failure(DatabaseError.failedToDelete))
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
    
    // Delete favorited pokemon by name
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
            completion(.failure(DatabaseError.failedToDelete))
        }
    }
    
    func unpackFromPokemonEntity(pokemonEntity: PokemonEntity) throws -> (PokemonDetailModel, String, UIImage) {
        
        // Abilities
        guard let entityAbilities = pokemonEntity.abilities else {
            throw DatabaseError.failedToConvert
        }
        let abilitiesString = entityAbilities.components(separatedBy: ", ")
        var abilities = [PokemonAbilitiesItem]()
        for abilityString in abilitiesString {
            let pokemonAbility = PokemonAbility(name: abilityString)
            let pokemonAbilityItem = PokemonAbilitiesItem(ability: pokemonAbility)
            abilities.append(pokemonAbilityItem)
        }
        
        // Types
        guard let entityTypes = pokemonEntity.types else {
            throw DatabaseError.failedToConvert
        }
        let typesString = entityTypes.components(separatedBy: ", ")
        var types = [PokemonType]()
        for typeString in typesString {
            let pokemonTypeDetail = PokemonTypeDetail(name: typeString)
            let pokemonType = PokemonType(type: pokemonTypeDetail)
            types.append(pokemonType)
        }
        
        // Stats
        let stats: [PokemonStats] = [
            PokemonStats(
                baseStat: Int(pokemonEntity.hp),
                stat: PokemonStat(name: "hp")
            ),
            PokemonStats(
                baseStat: Int(pokemonEntity.attack),
                stat: PokemonStat(name: "attack")
            ),
            PokemonStats(
                baseStat: Int(pokemonEntity.defense),
                stat: PokemonStat(name: "defense")
            ),
            PokemonStats(
                baseStat: Int(pokemonEntity.specialAttack),
                stat: PokemonStat(name: "special-attack")
            ),
            PokemonStats(
                baseStat: Int(pokemonEntity.specialDefense),
                stat: PokemonStat(name: "special-defense")
            ),
            PokemonStats(
                baseStat: Int(pokemonEntity.speed),
                stat: PokemonStat(name: "speed")
            )
        ]
        
        // Moves
        guard let entityMoves = pokemonEntity.moves else {
            throw DatabaseError.failedToConvert
        }
        let movesString = entityMoves.components(separatedBy: ", ")
        var moves = [PokemonMovesItem]()
        for moveString in movesString {
            let pokemonMove = PokemonMove(name: moveString)
            let pokemonMovesItem = PokemonMovesItem(move: pokemonMove)
            moves.append(pokemonMovesItem)
        }
        
        // Name
        guard let entityName = pokemonEntity.name else {
            throw DatabaseError.failedToConvert
        }
        
        // Image URL
        guard let imageUrl = pokemonEntity.imageUrl else {
            throw DatabaseError.failedToConvert
        }
        
        let detailModel = PokemonDetailModel(
            id: Int(pokemonEntity.id),
            name: entityName,
            height: Int(pokemonEntity.height),
            weight: Int(pokemonEntity.weight),
            abilities: abilities,
            types: types,
            stats: stats,
            moves: moves,
            sprites: PokemonSprites(
                other: OtherSprites(
                    officialArtwork: OfficialArtwork(
                        frontDefault: imageUrl
                    )
                )
            )
        )
        
        // Image
        guard let entityImage = pokemonEntity.image else {
            throw DatabaseError.failedToConvert
        }
        guard let image = entityImage.imageFromBase64 else {
            throw DatabaseError.failedToConvert
        }
        
        // Color name
        guard let entityColorName = pokemonEntity.color else {
            throw DatabaseError.failedToConvert
        }
        
        return (detailModel, entityColorName, image)
    }
    
    // Get PokemonEntityModel to save to CoreData based on current PokemonDetail data
    func convertToPokemonEntityModel(
        pokemonDetailModel: PokemonDetailModel,
        pokemonColorName: String,
        pokemonImage: UIImage) throws -> PokemonEntityModel {
        
        guard let imageBase64 = pokemonImage.base64 else {
            print("Failed to convert image into base64")
            throw DatabaseError.failedToConvert
        }
        
        // Get stats
        var hp = 0
        var attack = 0
        var defense = 0
        var spAttack = 0
        var spDefense = 0
        var speed = 0
        for pokemonStats in pokemonDetailModel.stats {
            switch pokemonStats.stat.name {
            case "hp":
                hp = pokemonStats.baseStat
            case "attack":
                attack = pokemonStats.baseStat
            case "defense":
                defense = pokemonStats.baseStat
            case "special-attack":
                spAttack = pokemonStats.baseStat
            case "special-defense":
                spDefense = pokemonStats.baseStat
            case "speed":
                speed = pokemonStats.baseStat
            default:
                print("Stat not found: \(pokemonStats.stat.name)")
            }
        }
        
        let abilities = pokemonDetailModel.abilities.map { $0.ability.name }.joined(separator: ", ")
        _ = abilities.dropLast()
        
        let types = pokemonDetailModel.types.map { $0.type.name }.joined(separator: ", ")
        _ = types.dropLast()
        
        let moves = pokemonDetailModel.moves.map { $0.move.name }.joined(separator: ", ")
        _ = moves.dropLast()
        
        let model = PokemonEntityModel(
            id: pokemonDetailModel.id,
            name: pokemonDetailModel.name,
            height: pokemonDetailModel.height,
            weight: pokemonDetailModel.weight,
            abilities: abilities,
            types: types,
            moves: moves,
            image: imageBase64,
            imageUrl: pokemonDetailModel.sprites.other.officialArtwork.frontDefault,
            color: pokemonColorName,
            hp: hp,
            attack: attack,
            defense: defense,
            specialAttack: spAttack,
            specialDefense: spDefense,
            speed: speed
        )
        
        return model
    }

}
