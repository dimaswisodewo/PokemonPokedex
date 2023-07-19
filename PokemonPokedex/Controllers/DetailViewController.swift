//
//  DetailViewController.swift
//  PokemonPokedex
//
//  Created by Dimas Wisodewo on 12/07/23.
//

import UIKit.UIImage

class DetailViewController: UIViewController {
    
    static let identifier = "DetailViewController"
    
    @IBOutlet weak var idLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
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
    
    @IBOutlet weak var scrollViewChildHeightConstraint: NSLayoutConstraint!
    
    private var pokemonImage: UIImage?
    
    private var detailAboutVC: DetailAboutViewController?
    private var detailStatsVC: DetailStatsViewController?
    private var detailMovesVC: DetailMovesViewController?
    
    private var isFavoriteFilled = false
    
    private var viewModel: DetailViewModel?
    private var unwrappedViewModel: DetailViewModel {
        get {
            return viewModel!
        }
    }
    
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

    func configure(model: PokemonDetailModel, pokemonImage: UIImage, pokemonColorName: String) {
        
        self.pokemonImage = pokemonImage
        self.viewModel = DetailViewModel(
            pokemonDetailModel: model,
            pokemonColorName: pokemonColorName)
    }
    
    func setupFavoriteButton() {
        unwrappedViewModel.setupFavoriteButton { [weak self] isExistsInDatabase in
            let systemName = isExistsInDatabase ? "heart.fill" : "heart"
            self?.favoriteButton.setImage(
                UIImage(systemName: systemName),
                for: .normal)
            self?.isFavoriteFilled = isExistsInDatabase
            self?.favoriteButton.isEnabled = true
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
            height = detailAboutVC?.height ?? 0
        // Base stats
        case 1:
            height = detailStatsVC?.height ?? 0
            detailStatsVC?.applyModelToView()
        // Moves
        case 2:
            height = scrollView.bounds.size.height
        default:
            height = detailAboutVC?.height ?? 0
        }
        
        scrollViewChildHeightConstraint.constant = height
//        scrollViewChild.layoutIfNeeded()
        
//        print("Set to \(height)")
    }
    
    private func applyDataToView() {
        
        let colorName = unwrappedViewModel.getPokemonColorName
        view.backgroundColor = UIColor.getPredefinedColor(name: colorName)
        
        idLabel.text = unwrappedViewModel.getPokemonFormattedId
        titleLabel.text = unwrappedViewModel.getPokemonDetailModel.name.capitalized
        detailImageView.image = pokemonImage
    }
    
    private func loadDetailAbout() {
        
        let storyboard = UIStoryboard(name: "DetailAboutStoryboard", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "DetailAboutViewController") as? DetailAboutViewController else { return }

        detailAboutVC = vc
        containerViewController.addSubview(vc.view)

        let width = self.containerViewController.bounds.size.width
        let height = vc.height
        vc.view.frame = CGRect(x: .zero, y: .zero, width: width, height: height)
//        print("Detail about page height: \(height)")

        vc.configure(with: unwrappedViewModel.getPokemonDetailModel)
    }
    
    private func loadDetailStats() {
        
        let storyboard = UIStoryboard(name: "DetailStatsStoryboard", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "DetailStatsViewController") as? DetailStatsViewController else { return }

        detailStatsVC = vc
        containerViewController.addSubview(vc.view)

        let width = self.containerViewController.bounds.size.width
        let height = vc.height
        vc.view.frame = CGRect(x: .zero, y: .zero, width: width, height: height)
//        print("Detail stats page height: \(height)")

        vc.configure(with: unwrappedViewModel.getPokemonDetailModel.stats)
    }
    
    private func loadDetailMoves() {
        
        let storyboard = UIStoryboard(name: "DetailMovesStoryboard", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "DetailMovesViewController") as? DetailMovesViewController else { return }

        detailMovesVC = vc
        containerViewController.addSubview(vc.view)

        vc.view.frame = self.containerViewController.bounds

        vc.configure(with: unwrappedViewModel.getPokemonDetailModel.moves)
    }
    
    @objc private func backButtonPressed() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc private func favoriteButtonPressed() {
        
        if !isFavoriteFilled {
            guard let detailImage = pokemonImage else { return }
            guard let encodedImage = detailImage.base64 else { return }
            unwrappedViewModel.setEncodedImage(base64Image: encodedImage)
        }
        
        isFavoriteFilled.toggle()
        if isFavoriteFilled {
            unwrappedViewModel.saveToCoreData { [weak self] isSaveSuccess in
                let systemName = isSaveSuccess ? "heart.fill" : "heart"
                self?.favoriteButton.setImage(
                    UIImage(systemName: systemName),
                    for: .normal)
                self?.isFavoriteFilled = isSaveSuccess
            }
        } else {
            unwrappedViewModel.deleteFromCoreData { [weak self] isDeleteSuccess in
                let systemName = isDeleteSuccess ? "heart" : "heart.fill"
                self?.favoriteButton.setImage(
                    UIImage(systemName: systemName),
                    for: .normal)
                self?.isFavoriteFilled = !isDeleteSuccess
            }
        }
    }
}
