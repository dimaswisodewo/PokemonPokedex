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
    
    private var pokemonName: String?
    private var pokemonColor: UIColor?
    private var pokemonImage: UIImage?
    private var pokemonDetailModel: PokemonDetailModel?
    
    private var detailAboutVC: DetailAboutViewController?
    private var detailStatsVC: DetailStatsViewController?
    private var detailMovesVC: DetailMovesViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        applyDataToView()
        
        loadDetailAbout()
        loadDetailStats()
        loadDetailMoves()
        
        configureViewController()
    }
    
    override func viewDidLayoutSubviews() {
        segmentedControlContainerView.roundCorners(corners: [.topLeft, .topRight], radius: 45)
    }

    func configure(model: PokemonDetailModel, pokemonImage: UIImage, pokemonColor: UIColor) {
        self.pokemonDetailModel = model
        self.pokemonName = model.name
        self.pokemonColor = pokemonColor
        self.pokemonImage = pokemonImage
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
}