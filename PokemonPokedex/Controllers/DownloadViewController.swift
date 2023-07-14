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
        
        tabBarController?.tabBar.isHidden = false
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let entity = downloadedPokemon[indexPath.row]
        
        guard let image = entity.image else { return }
        let pokemonSprite = PokemonSprites(frontDefault: "")
        
        // Abilities
        guard let unwrappedAbilities = entity.abilities else { return }
        let abilitiesString = unwrappedAbilities.components(separatedBy: ", ")
        var abilities = [PokemonAbilitiesItem]()
        for abilityString in abilitiesString {
            let pokemonAbility = PokemonAbility(name: abilityString)
            let pokemonAbilityItem = PokemonAbilitiesItem(ability: pokemonAbility)
            abilities.append(pokemonAbilityItem)
        }
        
        // Types
        guard let unwrappedTypes = entity.types else { return }
        let typesString = unwrappedTypes.components(separatedBy: ", ")
        var types = [PokemonType]()
        for typeString in typesString {
            let pokemonTypeDetail = PokemonTypeDetail(name: typeString)
            let pokemonType = PokemonType(type: pokemonTypeDetail)
            types.append(pokemonType)
        }
        
        // Stats
        let stats: [PokemonStats] = [
            PokemonStats(baseStat: Int(entity.hp), stat: PokemonStat(name: "hp")),
            PokemonStats(baseStat: Int(entity.attack), stat: PokemonStat(name: "attack")),
            PokemonStats(baseStat: Int(entity.defense), stat: PokemonStat(name: "defense")),
            PokemonStats(baseStat: Int(entity.specialAttack), stat: PokemonStat(name: "special-attack")),
            PokemonStats(baseStat: Int(entity.specialDefense), stat: PokemonStat(name: "special-defense")),
            PokemonStats(baseStat: Int(entity.speed), stat: PokemonStat(name: "speed"))
        ]
        
        // Moves
        guard let unwrappedMoves = entity.moves else { return }
        var movesString = unwrappedMoves.components(separatedBy: ", ")
        var moves = [PokemonMovesItem]()
        for moveString in movesString {
            let pokemonMove = PokemonMove(name: moveString)
            let pokemonMovesItem = PokemonMovesItem(move: pokemonMove)
            moves.append(pokemonMovesItem)
        }
        
        let detailModel = PokemonDetailModel(
            id: Int(entity.id),
            name: entity.name ?? "",
            height: Int(entity.height),
            weight: Int(entity.weight),
            abilities: abilities,
            types: types,
            stats: stats,
            moves: moves,
            sprites: pokemonSprite
        )
        
        guard let vc = storyboard?.instantiateViewController(withIdentifier: DetailViewController.identifier) as? DetailViewController else { return }
        vc.configure(
            model: detailModel,
            pokemonImage: image.imageFromBase64 ?? UIImage(),
            pokemonColorName: entity.color ?? "",
            pokemonColor: UIColor.getPredefinedColor(name: entity.color ?? "")
        )
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
    
}
