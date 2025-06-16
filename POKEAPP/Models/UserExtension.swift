//
//  RegisterView.swift
//  POKEAPP
//
//  Created by João Vitor De Freitas, Carlos Hobmeier, Amanda Queiroz e Theo Nicoleli on 13/06/25.
//

extension Usuario {
    public var favoritosArray: [Favorito] {
        let set = favoritos as? Set<Favorito> ?? []
        return set.sorted {
            $0.pokemonName ?? "" < $1.pokemonName ?? ""
        }
    }
}

