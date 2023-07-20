//
//  DetailStatsViewController.swift
//  PokemonPokedex
//
//  Created by Dimas Wisodewo on 12/07/23.
//

import UIKit

class DetailStatsViewController: UIViewController {
    
    let height: CGFloat = 360
    
    @IBOutlet weak var hpValueLabel: UILabel!
    
    @IBOutlet weak var hpProgress: UIProgressView!
    
    @IBOutlet weak var attackValueLabel: UILabel!
    
    @IBOutlet weak var attackProgress: UIProgressView!
    
    @IBOutlet weak var defenseValueLabel: UILabel!
    
    @IBOutlet weak var defenseProgress: UIProgressView!
    
    @IBOutlet weak var specialAttackValueLabel: UILabel!
    
    @IBOutlet weak var specialAttackProgress: UIProgressView!
    
    @IBOutlet weak var specialDefenseValueLabel: UILabel!
    
    @IBOutlet weak var specialDefenseProgress: UIProgressView!
    
    @IBOutlet weak var speedValueLabel: UILabel!
    
    @IBOutlet weak var speedProgress: UIProgressView!
    
    private var statsModel: [PokemonStats] = [PokemonStats]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func configure(with stats: [PokemonStats]) {
        statsModel = stats
    }
    
    func applyModelToView() {
        
        let maxStat = Float(100.0)
        
        let hpBase = Float(statsModel[0].baseStat)
        let hp = hpBase / maxStat
        hpValueLabel.text = String(Int(hpBase))
        hpProgress.tintColor = getProgressTintColor(inputValue: hpBase)
        
        let attackBase = Float(statsModel[1].baseStat)
        let attack = attackBase / maxStat
        attackValueLabel.text = String(Int(attackBase))
        attackProgress.tintColor = getProgressTintColor(inputValue: attackBase)
        
        let defenseBase = Float(statsModel[2].baseStat)
        let defense = defenseBase / maxStat
        defenseValueLabel.text = String(Int(defenseBase))
        defenseProgress.tintColor =  getProgressTintColor(inputValue: defenseBase)
        
        let spAttackBase = Float(statsModel[3].baseStat)
        let spAttack = spAttackBase / maxStat
        specialAttackValueLabel.text = String(Int(spAttackBase))
        specialAttackProgress.tintColor = getProgressTintColor(inputValue: spAttackBase)
        
        let spDefenseBase = Float(statsModel[4].baseStat)
        let spDefense = spDefenseBase / maxStat
        specialDefenseValueLabel.text = String(Int(spDefenseBase))
        specialDefenseProgress.tintColor = getProgressTintColor(inputValue: spDefenseBase)
        
        let speedBase = Float(statsModel[5].baseStat)
        let speed = speedBase / maxStat
        speedValueLabel.text = String(Int(speedBase))
        speedProgress.tintColor = getProgressTintColor(inputValue: speedBase)
        
        UIView.animate(withDuration: 1.0) { [weak self] in
            self?.hpProgress.setProgress(hp, animated: true)
            self?.attackProgress.setProgress(attack, animated: true)
            self?.defenseProgress.setProgress(defense, animated: true)
            self?.specialAttackProgress.setProgress(spAttack, animated: true)
            self?.specialDefenseProgress.setProgress(spDefense, animated: true)
            self?.speedProgress.setProgress(speed, animated: true)
        }
    }
    
    private func getProgressTintColor(inputValue: Float) -> UIColor {
        
        if inputValue > 100.0 {
            return UIColor(named: "PrimaryBlue")!
        } else if inputValue > 50.0 {
            return UIColor(named: "PrimaryGreen")!
        } else {
            return UIColor(named: "PrimaryRed")!
        }
    }
}
