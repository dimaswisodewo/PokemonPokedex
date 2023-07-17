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
            downloadedTableView.separatorStyle = .none
            downloadedTableView.delegate = self
            downloadedTableView.dataSource = self
            downloadedTableView.register(
                UINib(nibName: DownloadTableViewCell.identifier, bundle: nil),
                forCellReuseIdentifier: DownloadTableViewCell.identifier
            )
        }
    }
    
    private var alertTextField: UITextField? {
        didSet {
            print("DidSet")
            alertTextField?.addTarget(self, action: #selector(alertTextFieldEditingChanged), for: .editingChanged)
        }
    }
    
    private var downloadedPokemon = [PokemonEntity]()
    
    private let maxPokemonNameLength = 24
    private var currentlyEditing: String = ""
    
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
    
    // Keep pokemon name under max length
    @objc private func alertTextFieldEditingChanged() {
        guard let textField = alertTextField else { return }
        if let textFieldValue = textField.text {
            if textFieldValue.count > maxPokemonNameLength {
                let fixedValue = textFieldValue.dropLast()
                textField.text = String(fixedValue)
            }
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
    
    private func deleteDownloadedPokemonById(pokemonId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        DataPersistenceManager.shared.deletePokemonData(id: pokemonId, completion: completion)
    }
    
    private func showAlertEditPokemonData(pokemonId: Int, indexPath: IndexPath) {
        let alert = UIAlertController(title: "Change Name", message: "Change pokemon name.", preferredStyle: .alert)
        
        // Add a text field within the alert
        alert.addTextField { [weak self] textField in
            guard let unwrappedSelf = self else { return }
            textField.placeholder = "Insert pokemon name"
            unwrappedSelf.currentlyEditing = unwrappedSelf.downloadedPokemon[indexPath.row].name?.capitalized ?? ""
            textField.text = unwrappedSelf.currentlyEditing
            unwrappedSelf.alertTextField = textField
        }
        
        // Alert action
        let alertAction = UIAlertAction(
            title: NSLocalizedString("OK", comment: "OK pressed"),
            style: .default) { [weak self] action in
                guard let unwrappedSelf = self else { return }
                guard let textField = unwrappedSelf.alertTextField else { return }
                guard let inputText = textField.text else { return }
                if unwrappedSelf.currentlyEditing.lowercased() == inputText.lowercased() { return } // No changes
                DataPersistenceManager.shared.updatePokemonName(
                    pokemonId: pokemonId,
                    newName: inputText) { result in
                        switch result {
                        case .success():
                            print("Updated")
                            DispatchQueue.main.async {
                                unwrappedSelf.downloadedTableView.reloadData()
                            }
                        case .failure(let error):
                            print(error)
                        }
                    }
            }
        
        alert.addAction(alertAction)
        
        present(alert, animated: true, completion: nil)
    }
}

extension DownloadViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        downloadedPokemon.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        do {
            guard let cell = downloadedTableView.dequeueReusableCell(withIdentifier: DownloadTableViewCell.identifier) as? DownloadTableViewCell else {
                throw APIError.failedToFetchData
            }
            
            let model = downloadedPokemon[indexPath.row]
            guard let name = model.name else { throw DatabaseError.failedToConvert }
            guard let color = model.color else { throw DatabaseError.failedToConvert }
            guard let imageString = model.image else { throw DatabaseError.failedToConvert }
            guard let image = imageString.imageFromBase64 else { throw DatabaseError.failedToConvert }
            
            let id = model.id
            
            cell.configure(with: name.capitalized)
            cell.configureId(with: String(id))
            cell.configureColor(with: color)
            cell.configureImage(with: image)
            
            return cell
        } catch {
            let defaultCell = UITableViewCell()
            var contentConfig = defaultCell.defaultContentConfiguration()
            contentConfig.text = downloadedPokemon[indexPath.row].name
            
            defaultCell.contentConfiguration = contentConfig
            return defaultCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Unpack entity
        let entity = downloadedPokemon[indexPath.row]
        var unpackedEntity: (PokemonDetailModel, String, UIImage)?
        do {
            unpackedEntity = try DataPersistenceManager.shared.unpackFromPokemonEntity(pokemonEntity: entity)
        } catch {
            print(error)
        }
        
        guard let unwrappedUnpackedEntity = unpackedEntity else { return }
        let detailModel = unwrappedUnpackedEntity.0
        let colorName = unwrappedUnpackedEntity.1
        let image = unwrappedUnpackedEntity.2
        
        // Move to Pokemon Detail Page
        guard let vc = storyboard?.instantiateViewController(withIdentifier: DetailViewController.identifier) as? DetailViewController else { return }
        
        vc.configure(
            model: detailModel,
            pokemonImage: image,
            pokemonColorName: colorName,
            pokemonColor: UIColor.getPredefinedColor(name: colorName)
        )
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        160
    }
    
    // Disable default trailing delete action when swiping cell on OS lower than iOS 13
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .none
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let fontMetrics = UIFontMetrics(forTextStyle: .body)
            .scaledFont(
                for: UIFont(name: "Poppins-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12),
                maximumPointSize: 12)
        
        let edit = UIContextualAction(style: .normal, title: nil) { [weak self] action, view, completion in
            self?.handleEditSwipeAction(indexPath: indexPath)
            completion(true)
        }
        edit.backgroundColor = .white
        let namelabel = UILabel()
        namelabel.numberOfLines = 2
        namelabel.textAlignment = .center
        namelabel.text = "Change\nName"
        namelabel.textColor = .systemBlue
        namelabel.font = fontMetrics
        namelabel.sizeToFit()
        edit.image = UIImage(view: namelabel)
        
        let delete = UIContextualAction(style: .destructive, title: nil) { [weak self] action, view, completion in
            self?.handleDeleteSwipeAction(indexPath: indexPath)
            completion(true)
        }
        delete.backgroundColor = .white
        let deleteLabel = UILabel()
        deleteLabel.text = "Delete"
        deleteLabel.textColor = .systemRed
        deleteLabel.font = fontMetrics
        deleteLabel.sizeToFit()
        delete.image = UIImage(view: deleteLabel)
        
        let configuration = UISwipeActionsConfiguration(actions: [delete, edit])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    private func handleEditSwipeAction(indexPath: IndexPath) {
        let pokemonId = Int(downloadedPokemon[indexPath.row].id)
        showAlertEditPokemonData(pokemonId: pokemonId, indexPath: indexPath)
    }
    
    private func handleDeleteSwipeAction(indexPath: IndexPath) {
        let dataToDelete = downloadedPokemon[indexPath.row]
        let pokemonId = Int(dataToDelete.id)
        deleteDownloadedPokemonById(pokemonId: pokemonId) { result in
            switch result {
            case .success():
                print("Deleted")
                DispatchQueue.main.async { [weak self] in
                    self?.downloadedPokemon.remove(at: indexPath.row)
                    self?.downloadedTableView.deleteRows(at: [indexPath], with: .left)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
