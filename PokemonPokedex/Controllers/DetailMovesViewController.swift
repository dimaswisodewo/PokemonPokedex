//
//  DetailMovesViewController.swift
//  PokemonPokedex
//
//  Created by Dimas Wisodewo on 13/07/23.
//

import UIKit

class DetailMovesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    private var moves: [PokemonMovesItem] = [PokemonMovesItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    func configure(with model: [PokemonMovesItem]) {
        moves = model
    }
}

extension DetailMovesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        moves.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else { return UITableViewCell() }
        
        var contentConfig = cell.defaultContentConfiguration()
        contentConfig.text = moves[indexPath.row].move.name.capitalized
        contentConfig.textProperties.font = UIFont(name: "Poppins-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        
        cell.contentConfiguration = contentConfig
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        90
    }
}
