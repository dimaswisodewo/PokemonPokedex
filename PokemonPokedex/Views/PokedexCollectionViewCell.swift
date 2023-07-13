//
//  PokedexCollectionViewCell.swift
//  PokemonPokedex
//
//  Created by Dimas Wisodewo on 12/07/23.
//

import UIKit

class PokedexCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PokedexCollectionViewCell"
    
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.clipsToBounds = true
            containerView.layer.cornerRadius = 24
        }
    }
    
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var idLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func layoutSubviews() {
        backgroundImage.alpha = CGFloat(0.5)
    }
    
    func configure(with model: PokemonModel) {
        nameLabel.text = model.name.capitalized
    }
    
    func configureId(with id: String) {
        var editedString = "#"
        for _ in 0..<(4-id.count) {
            editedString.append("0")
        }
        editedString.append(id)
        idLabel.text = editedString
    }
    
    func configureColor(with model: PokemonSpeciesDetail) {
        containerView.backgroundColor = UIColor.getPredefinedColor(name: model.color.name)
    }
    
    func configureImage(with url: String) {
        guard let url = URL(string: url) else { return }
        imageView.sd_setImage(with: url)
    }
    
}
