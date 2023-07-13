//
//  PokemonModel.swift
//  PokemonPokedex
//
//  Created by Dimas Wisodewo on 12/07/23.
//

import Foundation

struct PokemonResponse: Decodable {
    var results: [PokemonModel]
}

struct PokemonModel: Decodable {
    var name: String
    var url: String
}

struct PokemonDetailModel: Decodable {
    var id: Int
    var name: String
    var height: Int
    var weight: Int
    var abilities: [PokemonAbilitiesItem]
    var types: [PokemonType]
    var stats: [PokemonStats]
    var moves: [PokemonMovesItem]
    var sprites: PokemonSprites
}

struct PokemonAbilitiesItem: Decodable {
    var ability: PokemonAbility
}

struct PokemonAbility: Decodable {
    var name: String
}
        
struct PokemonSpeciesDetail: Decodable {
    var id: Int
    var color: PokemonColor
}

struct PokemonColor: Decodable {
    var name: String
}

struct PokemonSprites: Decodable {
    var frontDefault: String
    
    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
    }
}

struct PokemonType: Decodable {
    var type: PokemonTypeDetail
}

struct PokemonTypeDetail: Decodable {
    var name: String
}

struct PokemonStats: Decodable {
    var baseStat: Int
    var stat: PokemonStat
    
    enum CodingKeys: String, CodingKey {
        case baseStat = "base_stat"
        case stat = "stat"
    }
}

struct PokemonMovesItem: Decodable {
    var move: PokemonMove
}

struct PokemonMove: Decodable {
    var name: String
}

struct PokemonStat: Decodable {
    var name: String
}
