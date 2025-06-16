//
//  RegisterView.swift
//  POKEAPP
//
//  Created by João Vitor De Freitas, Carlos Hobmeier, Amanda Queiroz e Theo Nicoleli on 10/06/25.
//

import SwiftUI

@main
struct PokeApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
            WindowGroup {
                RootView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }
    }
