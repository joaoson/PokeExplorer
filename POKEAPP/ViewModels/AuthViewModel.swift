//
//  RegisterView.swift
//  POKEAPP
//
//  Created by João Vitor De Freitas, Carlos Hobmeier, Amanda Queiroz e Theo Nicoleli on 11/06/25.
//


import SwiftUI
import CoreData

class AuthViewModel: ObservableObject {
    @Published var currentUser: Usuario?
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        loadLoggedUser()
    }

    // Cadastro
    func register(nomeDeUsuario: String, email: String, senha: String) -> Bool {
        guard !email.isEmpty, email.contains("@"),
              senha.count >= 6, !nomeDeUsuario.isEmpty else {
            return false
        }

        let newUser = Usuario(context: context)
        newUser.id = UUID()
        newUser.nomeDeUsuario = nomeDeUsuario
        newUser.email = email
        newUser.senha = senha

        save()
        currentUser = newUser
        UserDefaults.standard.set(newUser.id?.uuidString, forKey: "loggedUserID")
        return true
    }

    // Login
    func login(email: String, senha: String) -> Bool {
        let request = Usuario.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@ AND senha == %@", email, senha)

        if let user = try? context.fetch(request).first {
            currentUser = user
            UserDefaults.standard.set(user.id?.uuidString, forKey: "loggedUserID")
            return true
        }
        return false
    }

    // Logout
    func logout() {
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: "loggedUserID")
        try? context.save()

    }

    // Carregar usuário logado
    private func loadLoggedUser() {
        if let userID = UserDefaults.standard.string(forKey: "loggedUserID"),
           let uuid = UUID(uuidString: userID) {
            let request = Usuario.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", uuid as CVarArg)
            currentUser = try? context.fetch(request).first
        }
    }

    func save() {
        do {
            try context.save()
        } catch {
            print("Erro ao salvar: \(error.localizedDescription)")
        }
    }
}
