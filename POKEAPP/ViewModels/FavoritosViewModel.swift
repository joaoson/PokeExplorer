//
//  RegisterView.swift
//  POKEAPP
//
//  Created by João Vitor De Freitas, Carlos Hobmeier, Amanda Queiroz e Theo Nicoleli on 13/06/25.
//

import SwiftUI
import CoreData

class FavoritosViewModel: ObservableObject {
    private let context: NSManagedObjectContext
    private let user: Usuario

    @Published private(set) var favoritos: [Favorito] = []

    init(context: NSManagedObjectContext, user: Usuario) {
        self.context = context
        self.user = user
        loadFavorites()
    }

    func loadFavorites() {
        let request: NSFetchRequest<Favorito> = Favorito.fetchRequest()
        request.predicate = NSPredicate(format: "usuario == %@", user)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Favorito.pokemonName, ascending: true)]
        
        do {
            favoritos = try context.fetch(request)
        } catch {
            print("❌ Error loading favorites: \(error.localizedDescription)")
            favoritos = []
        }
    }

    func isFavorito(pokemonID: Int64) -> Bool {
        favoritos.contains(where: { $0.pokemonID == pokemonID })
    }

    func toggleFavorito(pokemonID: Int64, pokemonName: String) {
        if let favorito = favoritos.first(where: { $0.pokemonID == pokemonID }) {
            context.delete(favorito)
        } else {
            let novo = Favorito(context: context)
            novo.id = UUID()
            novo.pokemonID = pokemonID
            novo.pokemonName = pokemonName
            novo.usuario = user
        }
        save()
    }

    func save() {
        do {
            try context.save()
            // ✅ Reload favorites after successful save to update the @Published array
            loadFavorites()
        } catch {
            print("❌ Error saving favorite: \(error.localizedDescription)")
        }
    }
}
