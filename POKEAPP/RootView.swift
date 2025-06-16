//
//  RegisterView.swift
//  POKEAPP
//
//  Created by João Vitor De Freitas, Carlos Hobmeier, Amanda Queiroz e Theo Nicoleli on 11/06/25.
//


import SwiftUI

struct RootView: View {
    @StateObject private var auth = AuthViewModel(context: PersistenceController.shared.container.viewContext)

    var body: some View {
        if auth.currentUser != nil {
            MainAppView(auth: auth)
        } else {
            LoginView(auth: auth)
        }
    }
}
