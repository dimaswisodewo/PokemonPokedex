//
//  DownloadTableViewCell.swift
//  PokemonPokedex
//
//  Created by Dimas Wisodewo on 14/07/23.
//

import UIKit

class DownloadTableViewCell: UITableViewCell {

    static let identifier = "DownloadTableViewCell"
    
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.layer.cornerRadius = 24
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var idLabel: UILabel!
    
    @IBOutlet weak var pokemonImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with name: String) {
        nameLabel.text = name
    }
    
    func configureId(with id: String) {
        var editedString = "#"
        for _ in 0..<(4-id.count) {
            editedString.append("0")
        }
        editedString.append(id)
        idLabel.text = editedString
    }
    
    func configureColor(with colorName: String) {
        containerView.backgroundColor = UIColor.getPredefinedColor(name: colorName)
    }
    
    func configureImage(with image: UIImage) {
        pokemonImageView.image = image
    }
}
