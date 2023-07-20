//
//  ViewController.swift
//  PokemonPokedex
//
//  Created by Dimas Wisodewo on 11/07/23.
//

import UIKit.UIImage

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
    
    private var viewModel: PokedexViewModel = PokedexViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Subscribe reload table view
        viewModel.reloadTableView = { [weak self] in
            self?.reloadCollectionView()
        }
        
        // Load from API
        viewModel.loadPokemons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Show tab bar
        tabBarController?.tabBar.isHidden = false
        
        // Handle when user starting the app offline
        if !viewModel.getIsUpdating, viewModel.getLoadedDataCount == 0 {
            viewModel.loadPokemons()
        }
    }
    
    private func reloadCollectionView() {
        DispatchQueue.main.async { [weak self] in
            self?.pokedexCollectionView.reloadData()
        }
    }
    
}

extension PokedexViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.getLoadedDataCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = pokedexCollectionView.dequeueReusableCell(
            withReuseIdentifier: PokedexCollectionViewCell.identifier,
            for: indexPath) as? PokedexCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        guard let model = viewModel.getLoadedData(onIndex: indexPath.row) else {
            return cell
        }
        guard let detail = viewModel.getLoadedDataDetails(onIndex: indexPath.row) else {
            return cell
        }
        guard let species = viewModel.getLoadedDataSpecies(onIndex: indexPath.row) else {
            return cell
        }
        
        cell.configure(with: model)
        cell.configureId(with: String(detail.id))
        cell.configureColor(with: species)
        cell.configureImage(with: detail.sprites.other.officialArtwork.frontDefault)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let vc = storyboard?.instantiateViewController(withIdentifier: DetailViewController.identifier) as? DetailViewController else { return }
        
        guard let model = viewModel.getLoadedDataDetails(onIndex: indexPath.row) else { return }
        guard let species = viewModel.getLoadedDataSpecies(onIndex: indexPath.row) else { return }

        guard let cell = collectionView.cellForItem(at: indexPath) as? PokedexCollectionViewCell else { return }
        guard let image = cell.imageView.image else { return }

        vc.configure(
            model: model,
            pokemonImage: image,
            pokemonColorName: species.color.name)

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
        
        if indexPath.item == (viewModel.getOffset - 1) && !viewModel.getIsUpdating {
            viewModel.loadPokemons()
        }
    }

}
