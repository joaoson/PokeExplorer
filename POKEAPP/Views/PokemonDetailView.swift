//
//  RegisterView.swift
//  POKEAPP
//
//  Created by João Vitor De Freitas, Carlos Hobmeier, Amanda Queiroz e Theo Nicoleli on 12/06/25.
//

import SwiftUI

struct PokemonDetailView: View {
    let pokemonEntry: PokemonListEntry
    @ObservedObject var viewModel: PokemonViewModel
    @ObservedObject var favoritosVM: FavoritosViewModel

    @State private var detail: PokemonDetail?
    @State private var isLoading = true
    
    // Animation states
    @State private var buttonScale: CGFloat = 1.0
    @State private var showPokeball = false
    @State private var pokeballScale: CGFloat = 0.1
    @State private var pokeballRotation: Double = 0
    @State private var pokeballOpacity: Double = 0
    @State private var sparkles: [SparkleParticle] = []
    @State private var showSparkles = false

    var body: some View {
        ZStack {
            backgroundView
            
            decorativeCircles
            
            mainContent
            
            animationOverlays
        }
        .navigationTitle(pokemonEntry.name.capitalized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.clear, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
        .task {
            await loadDetail()
        }
    }
    
    // MARK: - View Components
    
    private var backgroundView: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.2, green: 0.6, blue: 1.0),
                Color(red: 0.1, green: 0.4, blue: 0.8)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
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
    
    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                if isLoading {
                    loadingView
                } else if let detail = detail {
                    pokemonDetailContent(detail)
                } else {
                    errorView
                }
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)
            
            Text("Carregando Pokémon...")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
        }
        .padding(40)
        .background(Color.white.opacity(0.1))
        .cornerRadius(20)
        .padding(.horizontal, 24)
        .padding(.top, 40)
    }
    
    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("Falha ao carregar detalhes do Pokémon")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
        }
        .padding(40)
        .background(Color.white.opacity(0.1))
        .cornerRadius(20)
        .padding(.horizontal, 24)
        .padding(.top, 40)
    }
    
    private func pokemonDetailContent(_ detail: PokemonDetail) -> some View {
        VStack(spacing: 24) {
            pokemonImageCard(detail)
            typesSection(detail)
            statsSection(detail)
            abilitiesSection(detail)
            movesSection(detail)
            favoriteButton(detail)
        }
    }
    
    private func pokemonImageCard(_ detail: PokemonDetail) -> some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.9))
                    .frame(width: 200, height: 200)
                    .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
                
                AsyncImage(url: URL(string: detail.sprites.front_default ?? "")) { image in
                    image.resizable()
                         .scaledToFit()
                         .frame(width: 160, height: 160)
                } placeholder: {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Carregando...")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                    }
                }
            }
            
            Text(detail.name.capitalized)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
            
            Text("#\(String(format: "%03d", detail.id))")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(Color.black.opacity(0.3))
                .cornerRadius(15)
        }
        .padding(.top, 20)
    }
    
    private func typesSection(_ detail: PokemonDetail) -> some View {
        VStack(spacing: 12) {
            Text("Tipos")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            
            HStack(spacing: 12) {
                ForEach(detail.types, id: \.type.name) { type in
                    Text(type.type.name.capitalized)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(typeColor(for: type.type.name))
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(20)
        .padding(.horizontal, 24)
    }
    
    private func statsSection(_ detail: PokemonDetail) -> some View {
        VStack(spacing: 16) {
            Text("Estatísticas")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            
            HStack(spacing: 20) {
                StatCard(title: "Altura", value: "\(Double(detail.height) / 10.0) m", icon: "ruler")
                StatCard(title: "Peso", value: "\(Double(detail.weight) / 10.0) kg", icon: "scalemass")
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(20)
        .padding(.horizontal, 24)
    }
    
    private func abilitiesSection(_ detail: PokemonDetail) -> some View {
        VStack(spacing: 16) {
            Text("Habilidades")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            
            VStack(spacing: 8) {
                ForEach(detail.abilities, id: \.ability.name) { ability in
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 12))
                        
                        Text(ability.ability.name.capitalized.replacingOccurrences(of: "-", with: " "))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(20)
        .padding(.horizontal, 24)
    }
    
    private func movesSection(_ detail: PokemonDetail) -> some View {
        VStack(spacing: 16) {
            Text("Movimentos")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            
            VStack(spacing: 8) {
                ForEach(detail.moves.prefix(5), id: \.move.name) { move in
                    HStack {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.orange)
                            .font(.system(size: 12))
                        
                        Text(move.move.name.capitalized.replacingOccurrences(of: "-", with: " "))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(20)
        .padding(.horizontal, 24)
    }
    
    private func favoriteButton(_ detail: PokemonDetail) -> some View {
        Button {
            let wasNotFavorite = !favoritosVM.isFavorito(pokemonID: Int64(detail.id))
            
            favoritosVM.toggleFavorito(pokemonID: Int64(detail.id), pokemonName: detail.name.capitalized)
            
            if wasNotFavorite {
                triggerAllAnimations()
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: favoritosVM.isFavorito(pokemonID: Int64(detail.id)) ? "heart.fill" : "heart")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Text(favoritosVM.isFavorito(pokemonID: Int64(detail.id)) ? "Remover dos Favoritos" : "Adicionar aos Favoritos")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(favoriteButtonGradient(for: detail))
            .cornerRadius(25)
            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .scaleEffect(buttonScale)
        .padding(.horizontal, 24)
        .padding(.bottom, 30)
    }
    
    private func favoriteButtonGradient(for detail: PokemonDetail) -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: favoritosVM.isFavorito(pokemonID: Int64(detail.id))
                             ? [Color.red, Color.red.opacity(0.8)]
                             : [Color.yellow, Color.orange]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var animationOverlays: some View {
        ZStack {
            if showPokeball {
                PokeballView()
                    .scaleEffect(pokeballScale)
                    .rotationEffect(.degrees(pokeballRotation))
                    .opacity(pokeballOpacity)
            }
            
            if showSparkles {
                ForEach(sparkles.indices, id: \.self) { index in
                    SparkleView(particle: sparkles[index])
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func typeColor(for type: String) -> Color {
        switch type.lowercased() {
        case "fire": return Color.red
        case "water": return Color.blue
        case "grass": return Color.green
        case "electric": return Color.yellow
        case "psychic": return Color.purple
        case "ice": return Color.cyan
        case "dragon": return Color.indigo
        case "dark": return Color.black
        case "fairy": return Color.pink
        case "fighting": return Color.brown
        case "poison": return Color.purple.opacity(0.8)
        case "ground": return Color.orange.opacity(0.8)
        case "flying": return Color.blue.opacity(0.6)
        case "bug": return Color.green.opacity(0.7)
        case "rock": return Color.gray
        case "ghost": return Color.purple.opacity(0.6)
        case "steel": return Color.gray.opacity(0.8)
        default: return Color.gray
        }
    }
    
    // MARK: - Combined Animation Function
    
    // Trigger all animations simultaneously
    private func triggerAllAnimations() {
        // Start all animations at the same time
        triggerPokeballAnimation()
        triggerPulseAnimation()
        triggerConfettiAnimation()
    }
    
    // MARK: - Individual Animation Functions
    
    // 1. Pokéball Catch Animation
    private func triggerPokeballAnimation() {
        showPokeball = true
        pokeballOpacity = 1.0
        pokeballScale = 0.1
        pokeballRotation = 0
        
        // Pokéball appears and grows
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            pokeballScale = 1.2
        }
        
        // Pokéball shakes (catch attempt)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeInOut(duration: 0.1).repeatCount(6, autoreverses: true)) {
                pokeballRotation = 15
            }
        }
        
        // Success effect and disappear
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeOut(duration: 0.3)) {
                pokeballScale = 0.1
                pokeballOpacity = 0
            }
        }
        
        // Reset
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            showPokeball = false
            pokeballScale = 0.1
            pokeballRotation = 0
        }
    }
    
    // 2. Button Pulse Animation
    private func triggerPulseAnimation() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            buttonScale = 1.2
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                buttonScale = 0.95
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                buttonScale = 1.0
            }
        }
    }
    
    // 3. Confetti/Sparkle Animation
    private func triggerConfettiAnimation() {
        // Generate random sparkles around the center of the screen
        sparkles = (0..<15).map { _ in
            SparkleParticle(
                x: CGFloat.random(in: -80...80),
                y: CGFloat.random(in: -80...80),
                scale: CGFloat.random(in: 0.8...2.0),
                rotation: Double.random(in: 0...360),
                color: [.yellow, .orange, .pink, .purple, .blue, .green].randomElement() ?? .yellow
            )
        }
        
        showSparkles = true
        
        // Animate sparkles
        withAnimation(.easeOut(duration: 1.0)) {
            sparkles = sparkles.map { particle in
                var newParticle = particle
                newParticle.x *= 4
                newParticle.y *= 4
                newParticle.scale *= 0.1
                newParticle.rotation += 720
                return newParticle
            }
        }
        
        // Hide sparkles
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showSparkles = false
        }
    }

    // MARK: - Load Detail Function
    @MainActor
    func loadDetail() async {
        isLoading = true

        do {
            detail = try await PokeAPIService.shared.fetchPokemonDetail(name: pokemonEntry.name)
        } catch {
            print("Erro ao carregar detalhes: \(error.localizedDescription)")
            detail = nil
        }

        isLoading = false
    }
}

// MARK: - Custom Views for Animations

struct PokeballView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [.red, .white]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 80, height: 80)
            
            Rectangle()
                .fill(Color.black)
                .frame(width: 80, height: 5)
            
            Circle()
                .fill(Color.black)
                .frame(width: 25, height: 25)
            
            Circle()
                .fill(Color.white)
                .frame(width: 15, height: 15)
        }
    }
}

struct SparkleParticle {
    var x: CGFloat
    var y: CGFloat
    var scale: CGFloat
    var rotation: Double
    var color: Color
}

struct SparkleView: View {
    let particle: SparkleParticle
    
    var body: some View {
        Image(systemName: "sparkle")
            .font(.system(size: 20))
            .foregroundColor(particle.color)
            .scaleEffect(particle.scale)
            .rotationEffect(.degrees(particle.rotation))
            .offset(x: particle.x, y: particle.y)
    }
}

// MARK: - Stat Card Component

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
    }
}
