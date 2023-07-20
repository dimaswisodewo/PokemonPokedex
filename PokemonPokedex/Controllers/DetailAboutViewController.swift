//
//  DetailAboutViewController.swift
//  PokemonPokedex
//
//  Created by Dimas Wisodewo on 12/07/23.
//

import UIKit

class DetailAboutViewController: UIViewController {

    let height: CGFloat = 300
    
    @IBOutlet weak var heightLabel: UILabel!
    
    @IBOutlet weak var weightLabel: UILabel!
    
    @IBOutlet weak var abilitiesLabel: UILabel!
    
    @IBOutlet weak var typesLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func configure(with model: PokemonDetailModel) {
        heightLabel.text = "\(Float(model.height)/10.0) m"
        weightLabel.text = "\(Float(model.weight)/10.0) kg"
        
        let abilitiesText = model.abilities.map { $0.ability.name }.joined(separator: ", ")
        _ = abilitiesText.dropLast()
        abilitiesLabel.text = abilitiesText.capitalized
        
        let typesText = model.types.map { $0.type.name }.joined(separator: ", ")
        _ = typesText.dropLast()
        typesLabel.text = typesText.capitalized
    }
}
