//
//  RegisterView.swift
//  POKEAPP
//
//  Created by João Vitor De Freitas, Carlos Hobmeier, Amanda Queiroz e Theo Nicoleli on 13/06/25.
//


import SwiftUI
import CoreData

struct AllUsersView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Usuario.nomeDeUsuario, ascending: true)],
        animation: .default
    )
    private var users: FetchedResults<Usuario>

    @Environment(\.managedObjectContext) private var context

    var body: some View {
        NavigationView {
            List {
                ForEach(users) { user in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("👤 Username: \(user.nomeDeUsuario ?? "Unknown")")
                            .font(.headline)
                        Text("📧 Email: \(user.email ?? "Unknown")")
                            .foregroundColor(.secondary)
                        Text("📧 Email: \(user.senha ?? "Unknown")")
                            .foregroundColor(.secondary)
                        Text("🆔 ID: \(user.id?.uuidString ?? "N/A")")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("All Users")
        }
    }
}
