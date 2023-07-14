//
//  DetailViewController.swift
//  PokemonPokedex
//
//  Created by Dimas Wisodewo on 12/07/23.
//

import UIKit

class DetailViewController: UIViewController {
    
    static let identifier = "DetailViewController"
    
    @IBOutlet weak var idLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            guard let model = pokemonDetailModel else { return }
            titleLabel.text = model.name
        }
    }
    
    @IBOutlet weak var detailImageView: UIImageView! {
        didSet {
            detailImageView.clipsToBounds = true
            detailImageView.contentMode = .scaleAspectFit
        }
    }
    
    @IBOutlet weak var backButton: UIButton! {
        didSet {
            backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var favoriteButton: UIButton! {
        didSet {
            favoriteButton.isEnabled = false
            favoriteButton.addTarget(self, action: #selector(favoriteButtonPressed), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var segmentedControlContainerView: UIView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl! {
        didSet {
            segmentedControl.selectedSegmentIndex = 0
            segmentedControl.addTarget(self, action: #selector(configureViewController), for: .valueChanged)
        }
    }
    
    @IBOutlet weak var containerViewController: UIView!
    
    @IBOutlet weak var scrollViewChild: UIView! {
        didSet {
            scrollViewChild.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private var isFavoriteFilled = false
    
    private var pokemonName: String?
    private var pokemonColor: UIColor?
    private var pokemonColorName: String?
    private var pokemonImage: UIImage?
    private var pokemonDetailModel: PokemonDetailModel?
    
    private var detailAboutVC: DetailAboutViewController?
    private var detailStatsVC: DetailStatsViewController?
    private var detailMovesVC: DetailMovesViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setupFavoriteButton()
        applyDataToView()
        
        loadDetailAbout()
        loadDetailStats()
        loadDetailMoves()
        
        configureViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Hide tab bar
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        segmentedControlContainerView.roundCorners(corners: [.topLeft, .topRight], radius: 45)
    }

    func configure(model: PokemonDetailModel, pokemonImage: UIImage, pokemonColorName: String, pokemonColor: UIColor) {
        self.pokemonDetailModel = model
        self.pokemonName = model.name
        self.pokemonColorName = pokemonColorName
        self.pokemonColor = pokemonColor
        self.pokemonImage = pokemonImage
    }
    
    func setupFavoriteButton() {
        guard let unwrappedName = pokemonName else { return }
        DataPersistenceManager.shared.isPokemonExistsInDatabase(with: unwrappedName) { [weak self] result in
            
            guard let unwrappedSelf = self else { return }
            switch result {
            case .success(let isExists):
                unwrappedSelf.isFavoriteFilled = isExists
                let systemName = unwrappedSelf.isFavoriteFilled ? "heart.fill" : "heart"
                unwrappedSelf.favoriteButton.setImage(UIImage(systemName: systemName), for: .normal)
                unwrappedSelf.favoriteButton.isEnabled = true
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @objc func configureViewController() {
        
        let selectedSegmentIndex = segmentedControl.selectedSegmentIndex
        scrollView.showsVerticalScrollIndicator = selectedSegmentIndex < 2
        
        detailAboutVC?.view.isHidden = selectedSegmentIndex != 0
        detailStatsVC?.view.isHidden = selectedSegmentIndex != 1
        detailMovesVC?.view.isHidden = selectedSegmentIndex != 2
        
        var height: CGFloat = 0
        
        switch selectedSegmentIndex {
        // About
        case 0:
            height = detailAboutVC?.view.bounds.size.height ?? 0
        // Base stats
        case 1:
            height = detailStatsVC?.view.bounds.size.height ?? 0
            detailStatsVC?.applyModelToView()
        // Moves
        case 2:
            height = detailMovesVC?.view.bounds.size.height ?? 0
        default:
            height = detailAboutVC?.view.bounds.size.height ?? 0
        }
        
        scrollViewChild.frame.size.height = height
        print("Set to \(height)")
    }
    
    private func applyDataToView() {
        view.backgroundColor = pokemonColor ?? UIColor.lightGray.withAlphaComponent(0.5)
        guard let unwrappedModel = pokemonDetailModel else { return }
        titleLabel.text = unwrappedModel.name.capitalized
        detailImageView.image = pokemonImage
        
        let idString = String(unwrappedModel.id)
        var editedString = "#"
        for _ in 0..<(4-idString.count) {
            editedString.append("0")
        }
        editedString.append(idString)
        idLabel.text = editedString
    }
    
    private func loadDetailAbout() {
        let storyboard = UIStoryboard(name: "DetailAboutStoryboard", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "DetailAboutViewController") as? DetailAboutViewController else { return }
        
        detailAboutVC = vc
        containerViewController.addSubview(vc.view)
        
//        vc.view.frame = self.containerViewController.bounds
        let width = self.containerViewController.bounds.size.width
        let height = vc.view.bounds.size.height
        vc.view.frame = CGRect(x: .zero, y: .zero, width: width, height: height)
        print("Detail about page height: \(height)")
        
        vc.configure(with: self.pokemonDetailModel!)
    }
    
    private func loadDetailStats() {
        let storyboard = UIStoryboard(name: "DetailStatsStoryboard", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "DetailStatsViewController") as? DetailStatsViewController else { return }
        
        detailStatsVC = vc
        containerViewController.addSubview(vc.view)
        
//        vc.view.frame = self.containerViewController.bounds
        let width = self.containerViewController.bounds.size.width
        let height = vc.view.bounds.size.height
        vc.view.frame = CGRect(x: .zero, y: .zero, width: width, height: height)
        print("Detail stats page height: \(height)")
        
        vc.configure(with: self.pokemonDetailModel!.stats)
    }
    
    private func loadDetailMoves() {
        let storyboard = UIStoryboard(name: "DetailMovesStoryboard", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "DetailMovesViewController") as? DetailMovesViewController else { return }
        
        detailMovesVC = vc
        containerViewController.addSubview(vc.view)
        
        vc.view.frame = self.containerViewController.bounds
        
        vc.configure(with: self.pokemonDetailModel!.moves)
    }
    
    @objc private func backButtonPressed() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc private func favoriteButtonPressed() {
        
        // Change button image
        isFavoriteFilled.toggle()
        let systemName = isFavoriteFilled ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: systemName), for: .normal)
        
        if isFavoriteFilled {
            saveToCoreData()
        } else {
            deleteFromCoreData()
        }
    }
    
    // Save to Core Data
    private func saveToCoreData() {
        guard let model = getPokemonEntityModel() else { return }
        DataPersistenceManager.shared.addPokemonData(with: model) { [weak self] result in
            switch result {
            case .success():
                print("Saved to Core Data: \(model.name)")
            case .failure(let error):
                print("Failed to save to Core Data: \(model.name), error message: \(error)")
                // Undo button image change
                guard let unwrappedSelf = self else { return }
                unwrappedSelf.isFavoriteFilled.toggle()
                let systemName = unwrappedSelf.isFavoriteFilled ? "heart.fill" : "heart"
                unwrappedSelf.favoriteButton.setImage(UIImage(systemName: systemName), for: .normal)
            }
        }
    }
    
    // Delete from Core Data
    private func deleteFromCoreData() {
        guard let unwrappedName = pokemonName else { return }
        DataPersistenceManager.shared.deletePokemonData(with: unwrappedName) { [weak self] result in
            switch result {
            case .success():
                print("Deleted from Core Data: \(unwrappedName)")
            case .failure(let error):
                print("Failed to delete from Core Data: \(unwrappedName), error message: \(error)")
                // Undo button image change
                guard let unwrappedSelf = self else { return }
                unwrappedSelf.isFavoriteFilled.toggle()
                let systemName = unwrappedSelf.isFavoriteFilled ? "heart.fill" : "heart"
                unwrappedSelf.favoriteButton.setImage(UIImage(systemName: systemName), for: .normal)
            }
        }
    }
    
    // Get PokemonEntityModel to save to CoreData based on current PokemonDetail data
    private func getPokemonEntityModel() -> PokemonEntityModel? {
        
        guard let detailModel = pokemonDetailModel else { return nil }
        guard let detailImage = pokemonImage else { return nil }
        guard let color = pokemonColorName else { return nil }
        
        guard let imageBase64 = detailImage.base64 else {
            print("Failed to convert image into base64")
            return nil
        }
        
        // Get stats
        var hp = 0
        var attack = 0
        var defense = 0
        var spAttack = 0
        var spDefense = 0
        var speed = 0
        for pokemonStats in detailModel.stats {
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
        
        let abilities = detailModel.abilities.map { $0.ability.name }.joined(separator: ", ")
        _ = abilities.dropLast()
        
        let types = detailModel.types.map { $0.type.name }.joined(separator: ", ")
        _ = types.dropLast()
        
        let moves = detailModel.moves.map { $0.move.name }.joined(separator: ", ")
        _ = moves.dropLast()
        
        let model = PokemonEntityModel(
            id: detailModel.id,
            name: detailModel.name,
            height: detailModel.height,
            weight: detailModel.weight,
            abilities: abilities,
            types: types,
            moves: moves,
            image: imageBase64,
            color: color,
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
