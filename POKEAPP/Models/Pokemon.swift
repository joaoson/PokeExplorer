//
//  RegisterView.swift
//  POKEAPP
//
//  Created by João Vitor De Freitas, Carlos Hobmeier, Amanda Queiroz e Theo Nicoleli on 10/06/25.
//

import Foundation

struct PokemonListResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [PokemonListEntry]
}

struct PokemonListEntry: Codable, Identifiable {
    let name: String
    let url: String
    
    var id: Int {
        if let number = url.split(separator: "/").compactMap({ Int($0) }).last {
            return number
        }
        return UUID().hashValue
    }
    
    var imageURL: String {
        "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png"
    }
}

struct PokemonDetail: Codable {
    let id: Int
    let name: String
    let weight: Int
    let height: Int
    let types: [PokemonTypeEntry]
    let abilities: [PokemonAbilityEntry]
    let moves: [PokemonMoveEntry]
    let sprites: PokemonSprites
}

struct PokemonTypeEntry: Codable {
    let type: PokemonType
}

struct PokemonType: Codable {
    let name: String
}

struct PokemonAbilityEntry: Codable {
    let ability: PokemonAbility
}

struct PokemonAbility: Codable {
    let name: String
}

struct PokemonMoveEntry: Codable {
    let move: PokemonMove
}

struct PokemonMove: Codable {
    let name: String
}

struct PokemonSprites: Codable {
    let front_default: String?
}
