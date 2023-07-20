//
//  DownloadViewController.swift
//  PokemonPokedex
//
//  Created by Dimas Wisodewo on 14/07/23.
//

import UIKit.UIImage

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
            alertTextField?.addTarget(self, action: #selector(alertTextFieldEditingChanged), for: .editingChanged)
        }
    }
    
    private let maxPokemonNameLength = 24
    private var currentlyEditing: String = ""
    
    private let viewModel = DownloadViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Print Core Data SQLite file location
        print(viewModel.getDatabaseFileLocation)
        
        // Assign reload table functionality
        viewModel.reloadTable = {
            DispatchQueue.main.async { [weak self] in
                print("Reload table")
                self?.downloadedTableView.reloadData()
            }
        }
        
        // Assign delete rows functionality
        viewModel.deleteTableRowsAt = { indexPaths in
            DispatchQueue.main.async { [weak self] in
                print("Delete rows")
                self?.downloadedTableView.deleteRows(at: indexPaths, with: .left)
            }
        }
        
        viewModel.loadDownloadedPokemon()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        tabBarController?.tabBar.isHidden = false
        
        viewModel.refreshTableViewIfNeeded()
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
    
    private func deleteDownloadedPokemonByName(pokemonName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        DataPersistenceManager.shared.deletePokemonData(with: pokemonName, completion: completion)
    }
    
    private func showAlertEditPokemonData(pokemonName: String, indexPath: IndexPath) {
        let alert = UIAlertController(title: "Change Name", message: "Change pokemon name.", preferredStyle: .alert)
        
        // Add a text field within the alert
        alert.addTextField { [weak self] textField in
            textField.placeholder = "Insert pokemon name"
            guard let unwrappedSelf = self else { return }
            guard let model = unwrappedSelf.viewModel.getDownloadedPokemonOnIndex(index: indexPath.row) else { return}
            unwrappedSelf.currentlyEditing = model.name?.capitalized ?? ""
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
                
                unwrappedSelf.viewModel.updateDownloadedPokemonName(
                    oldName: pokemonName,
                    newName: inputText)
            }
        
        alert.addAction(alertAction)
        
        present(alert, animated: true, completion: nil)
    }
}

extension DownloadViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.getDownloadedPokemonCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = downloadedTableView.dequeueReusableCell(withIdentifier: DownloadTableViewCell.identifier) as? DownloadTableViewCell else {
            return UITableViewCell()
        }
        
        guard let model = viewModel.getDownloadedPokemonOnIndex(index: indexPath.row) else { return cell }
        
        cell.configureId(with: String(model.id))
        if let name = model.name {
            cell.configure(with: name.capitalized)
        }
        if let color = model.color {
            cell.configureColor(with: color)
        }
        if let encodedImage = model.image,
           let image = encodedImage.imageFromBase64 {
            cell.configureImage(with: image)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let unpackedEntity = viewModel.getUnpackedEntityOnIndex(index: indexPath.row) else { return }
        
        guard let image = unpackedEntity.2.imageFromBase64 else { return }
        let colorName = unpackedEntity.1
        let detailModel = unpackedEntity.0
        
        // Move to Pokemon Detail Page
        guard let vc = storyboard?.instantiateViewController(withIdentifier: DetailViewController.identifier) as? DetailViewController else { return }
        
        vc.configure(
            model: detailModel,
            pokemonImage: image,
            pokemonColorName: colorName)
        
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
        
        // Font metrics used to set font of UILabel
        let fontMetrics = UIFontMetrics(forTextStyle: .body)
            .scaledFont(
                for: UIFont(name: "Poppins-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14),
                maximumPointSize: 14)
        
        // Change Name Action
        let edit = UIContextualAction(style: .normal, title: nil) { [weak self] action, view, completion in
            self?.handleEditSwipeAction(indexPath: indexPath)
            completion(true)
        }
        
        /// Since we cannot change the font on `UIContextualAction`, we can just convert
        /// a `UILabel` into an image, then set it into the `UIContextualAction`
        let namelabel = UILabel()
        namelabel.numberOfLines = 2
        namelabel.textAlignment = .center
        namelabel.text = "Change\nName"
        namelabel.textColor = .systemBlue
        namelabel.font = fontMetrics
        namelabel.sizeToFit()
        edit.image = UIImage(view: namelabel)
        edit.backgroundColor = .systemBackground
        
        // Delete Action
        let delete = UIContextualAction(style: .destructive, title: nil) { [weak self] action, view, completion in
            self?.handleDeleteSwipeAction(indexPath: indexPath)
            completion(true)
        }
        
        /// Since we cannot change the font on `UIContextualAction`, we can just convert
        /// a `UILabel` into an image, then set it into the `UIContextualAction`
        let deleteLabel = UILabel()
        deleteLabel.text = "Delete"
        deleteLabel.textColor = .systemRed
        deleteLabel.font = fontMetrics
        deleteLabel.sizeToFit()
        delete.image = UIImage(view: deleteLabel)
        delete.backgroundColor = .systemBackground
        
        let configuration = UISwipeActionsConfiguration(actions: [delete, edit])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    private func handleEditSwipeAction(indexPath: IndexPath) {
        guard let pokemonName = viewModel.getDownloadedPokemonOnIndex(index: indexPath.row)?.name else { return }
        showAlertEditPokemonData(
            pokemonName: pokemonName,
            indexPath: indexPath)
    }
    
    private func handleDeleteSwipeAction(indexPath: IndexPath) {
        guard let pokemonName = viewModel.getDownloadedPokemonOnIndex(index: indexPath.row)?.name else { return }
        viewModel.deleteDownloadedPokemonByName(
            name: pokemonName,
            indexPath: indexPath)
    }
}
