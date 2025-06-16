//
//  RegisterView.swift
//  POKEAPP
//
//  Created by João Vitor De Freitas, Carlos Hobmeier, Amanda Queiroz e Theo Nicoleli on 13/06/25.
//

import SwiftUI

struct ListaFavoritosView: View {
    @ObservedObject var favoritosVM: FavoritosViewModel
    @FetchRequest var favoritos: FetchedResults<Favorito>
    
    @State private var searchText = ""
    @State private var showSearchResults = false
    
    init(usuario: Usuario) {
        _favoritos = FetchRequest<Favorito>(
            sortDescriptors: [NSSortDescriptor(keyPath: \Favorito.pokemonName, ascending: true)],
            predicate: NSPredicate(format: "usuario == %@", usuario)
        )
        self.favoritosVM = FavoritosViewModel(context: PersistenceController.shared.container.viewContext, user: usuario)
    }
    
    var filteredFavoritos: [Favorito] {
        if searchText.isEmpty {
            return Array(favoritos)
        } else {
            return favoritos.filter { favorito in
                favorito.pokemonName?.lowercased().contains(searchText.lowercased()) ?? false
            }
        }
    }

    var body: some View {
        ZStack {
            // Background gradient matching PokemonDetailView
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.2, green: 0.6, blue: 1.0),
                    Color(red: 0.1, green: 0.4, blue: 0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Decorative circles
            decorativeCircles
            
            VStack(spacing: 0) {
                // Custom search bar
                searchBarView
                
                if filteredFavoritos.isEmpty {
                    emptyStateView
                } else {
                    favoritesListView
                }
            }
        }
        .navigationTitle("Meus Favoritos")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.clear, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
    
    // MARK: - View Components
    
    private var decorativeCircles: some View {
        GeometryReader { geometry in
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 100, height: 100)
                .position(x: geometry.size.width * 0.15, y: geometry.size.height * 0.15)
            
            Circle()
                .fill(Color.white.opacity(0.06))
                .frame(width: 80, height: 80)
                .position(x: geometry.size.width * 0.85, y: geometry.size.height * 0.2)
            
            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 120, height: 120)
                .position(x: geometry.size.width * 0.9, y: geometry.size.height * 0.8)
        }
    }
    
    private var searchBarView: some View {
        HStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.7))
                    .font(.system(size: 16, weight: .medium))
                
                TextField("Buscar Pokémon...", text: $searchText)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.system(size: 16))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.2))
            .cornerRadius(25)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 15)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: searchText.isEmpty ? "heart.slash" : "magnifyingglass")
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            VStack(spacing: 8) {
                Text(searchText.isEmpty ? "Nenhum Favorito" : "Nenhum Resultado")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                
                Text(searchText.isEmpty ?
                     "Adicione Pokémon aos seus favoritos para vê-los aqui!" :
                     "Não foi possível encontrar '\(searchText)' nos seus favoritos")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 60)
    }
    
    private var favoritesListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(Array(filteredFavoritos.enumerated()), id: \.element.objectID) { index, fav in
                    Button {
                        // We'll handle navigation programmatically if needed
                    } label: {
                        NavigationLink(destination: PokemonDetailView(
                            pokemonEntry: createPokemonEntry(from: fav),
                            viewModel: PokemonViewModel(),
                            favoritosVM: favoritosVM
                        )) {
                            PokemonFavoriteCard(favorito: fav, index: index)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }
    
    // MARK: - Helper Functions
    
    private func imageURL(for pokemonID: Int64) -> String {
        return "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemonID).png"
    }
    
    private func createPokemonEntry(from favorito: Favorito) -> PokemonListEntry {
        return PokemonListEntry(
            name: favorito.pokemonName?.lowercased() ?? "unknown",
            url: "https://pokeapi.co/api/v2/pokemon/\(favorito.pokemonID)/"
        )
    }
}

// MARK: - Pokemon Favorite Card Component

struct PokemonFavoriteCard: View {
    let favorito: Favorito
    let index: Int
    
    @State private var isPressed = false
    @State private var cardOffset: CGFloat = 50
    @State private var cardOpacity: Double = 0
    
    var body: some View {
        HStack(spacing: 16) {
            // Pokemon Image with Pokeball background
            ZStack {
                // Pokeball-inspired background
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white,
                                Color.white.opacity(0.9)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                
                // Pokeball line
                Rectangle()
                    .fill(Color.black.opacity(0.1))
                    .frame(width: 80, height: 2)
                
                // Pokemon Image
                AsyncImage(url: URL(string: imageURL(for: favorito.pokemonID))) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 65, height: 65)
                } placeholder: {
                    VStack(spacing: 4) {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.gray)
                        
                        Text("...")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            // Pokemon Info
            VStack(alignment: .leading, spacing: 8) {
                Text(favorito.pokemonName?.capitalized ?? "Unknown")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                
                HStack(spacing: 8) {
                    Text("#\(String(format: "%03d", favorito.pokemonID))")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(12)
                    
                    // Favorite heart indicator
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 14, weight: .bold))
                        .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                }
            }
            
            Spacer()
            
            // Arrow indicator
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.7))
                .font(.system(size: 16, weight: .bold))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.15))
                .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
        )
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .offset(x: cardOffset)
        .opacity(cardOpacity)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1)) {
                cardOffset = 0
                cardOpacity = 1
            }
        }
        .contextMenu {
            Button(role: .destructive) {
                deleteFavorite()
            } label: {
                Label("Remover dos Favoritos", systemImage: "heart.slash")
            }
        }
    }
    
    private func imageURL(for pokemonID: Int64) -> String {
        return "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemonID).png"
    }
    
    private func deleteFavorite() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            cardOffset = 100
            cardOpacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            PersistenceController.shared.container.viewContext.delete(favorito)
            try? PersistenceController.shared.container.viewContext.save()
        }
    }
}
