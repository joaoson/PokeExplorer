//
//  RegisterView.swift
//  POKEAPP
//
//  Created by João Vitor De Freitas, Carlos Hobmeier, Amanda Queiroz e Theo Nicoleli on 10/06/25.
//
import SwiftUI

struct PokemonListView: View {
    @StateObject private var viewModel = PokemonViewModel()
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    @State private var isInitialLoading = true
    @State private var pokeballRotation: Double = 0
    @State private var pokeballScale: CGFloat = 1.0
    @State private var pokeballOffset: CGFloat = 0
    @State private var pokeballOpacity: Double = 1.0
    @State private var showList = false
    
    @State private var isPaginationMode = false

    var body: some View {
        ZStack {
            backgroundView
            
            if showList {
                mainContentView
            }
            
            if isInitialLoading {
                loadingOverlayView
            }
        }
        .navigationTitle("Pokédex")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await loadWithAnimation()
        }
    }
    
    // MARK: - Extracted Views
    
    private var backgroundView: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.6, blue: 0.9),
                    Color(red: 0.2, green: 0.8, blue: 1.0),
                    Color(red: 0.3, green: 0.9, blue: 0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            floatingElementsView
        }
    }
    
    private var floatingElementsView: some View {
        GeometryReader { geometry in
            Group {
                // Floating Pokeballs
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 150, height: 150)
                    .position(x: geometry.size.width * 0.85, y: geometry.size.height * 0.15)
                
                Circle()
                    .fill(Color.red.opacity(0.06))
                    .frame(width: 100, height: 100)
                    .position(x: geometry.size.width * 0.1, y: geometry.size.height * 0.3)
                
                Circle()
                    .fill(Color.yellow.opacity(0.05))
                    .frame(width: 80, height: 80)
                    .position(x: geometry.size.width * 0.9, y: geometry.size.height * 0.8)
            }
        }
    }
    
    private var mainContentView: some View {
        Group {
            if viewModel.pokemons.isEmpty && !viewModel.isLoading {
                emptyStateView
            } else {
                pokemonListView
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            // Sad Pokeball
            sadPokeballView
            
            emptyStateTextView
            
            retryButtonView
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var sadPokeballView: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 100, height: 100)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            
            Circle()
                .fill(Color.red)
                .frame(width: 100, height: 100)
                .mask(
                    Rectangle()
                        .frame(width: 100, height: 50)
                        .offset(y: -25)
                )
            
            Rectangle()
                .fill(Color.black)
                .frame(width: 100, height: 4)
            
            Circle()
                .fill(Color.white)
                .frame(width: 24, height: 24)
                .overlay(
                    Circle()
                        .stroke(Color.black, lineWidth: 2)
                )
        }
        .opacity(0.7)
    }
    
    private var emptyStateTextView: some View {
        VStack(spacing: 12) {
            Text("Oops! No Pokémon Found")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
            
            Text("The Pokémon seem to be hiding!\nCheck your connection and try again.")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
        }
    }
    
    private var retryButtonView: some View {
        Button(action: {
            Task {
                await viewModel.refreshPokemons()
            }
        }) {
            HStack {
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(.white)
                Text("Try Again")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.orange, Color.red]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(25)
            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
    
    private var pokemonListView: some View {
        VStack(spacing: 0) {
            // Enhanced Mode Toggle
            ModeToggleView(isPaginationMode: $isPaginationMode) {
                Task {
                    await viewModel.switchMode(toPagination: isPaginationMode)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            
            // Pokemon Grid with enhanced styling
            pokemonScrollView
            
            // Bottom Controls
            bottomControlsView
        }
    }
    
    private var pokemonScrollView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.pokemons) { pokemon in
                    NavigationLink(destination: destinationView(for: pokemon)) {
                        PokemonCardView(pokemon: pokemon)
                            .onAppear {
                                if !isPaginationMode && pokemon.id == viewModel.pokemons.last?.id {
                                    Task {
                                        await viewModel.loadMorePokemons()
                                    }
                                }
                            }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .scrollIndicators(.hidden)
        .refreshable {
            await viewModel.refreshPokemons()
        }
    }
    
    private func destinationView(for pokemon: PokemonListEntry) -> some View {
        PokemonDetailView(
            pokemonEntry: pokemon,
            viewModel: viewModel,
            favoritosVM: FavoritosViewModel(
                context: PersistenceController.shared.container.viewContext,
                user: AuthViewModel(context: PersistenceController.shared.container.viewContext).currentUser!
            )
        )
    }
    
    private var bottomControlsView: some View {
        Group {
            if isPaginationMode {
                PaginationControlsView(viewModel: viewModel)
            } else {
                InfiniteScrollControlsView(viewModel: viewModel)
            }
        }
    }
    
    private var loadingOverlayView: some View {
        ZStack {
            // Animated background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.3, blue: 0.8),
                    Color(red: 0.2, green: 0.5, blue: 0.9)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            loadingContentView
        }
    }
    
    private var loadingContentView: some View {
        VStack(spacing: 30) {
            LoadingPokeballView()
                .rotationEffect(.degrees(pokeballRotation))
                .scaleEffect(pokeballScale)
                .offset(y: pokeballOffset)
                .opacity(pokeballOpacity)
            
            loadingTextView
        }
    }
    
    private var loadingTextView: some View {
        VStack(spacing: 12) {
            Text("Loading Pokédex...")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                .opacity(pokeballOpacity)
            
            if viewModel.isLoading {
                Text("Connecting to Professor Oak's Database...")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                    .opacity(pokeballOpacity)
            }
        }
    }
    
    // MARK: - Loading Animation Function
    
    @MainActor
    private func loadWithAnimation() async {
        print("🎬 Starting loading animation...")
        
        // Start spinning animation
        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            pokeballRotation = 360
        }
        
        // Load Pokemon data with timeout
        print("📡 Loading Pokemon data...")
        
        let loadingTask = Task {
            await viewModel.loadPokemons()
        }
        
        let timeoutTask = Task {
            try? await Task.sleep(nanoseconds: 10_000_000_000) // 10 seconds
        }
        
        await loadingTask.value
        timeoutTask.cancel()
        
        print("✅ Pokemon data loaded, count: \(viewModel.pokemons.count)")
        
        // Ensure minimum loading time for smooth animation
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        print("🎭 Starting exit animation...")
        // Stop spinning and start exit animation
        withAnimation(.easeInOut(duration: 0.4)) {
            pokeballOffset = -100
            pokeballOpacity = 0
            pokeballScale = 0.8
        }
        
        // Wait for exit animation to complete
        try? await Task.sleep(nanoseconds: 400_000_000)
        
        print("📱 Showing Pokemon list...")
        isInitialLoading = false
        
        withAnimation(.easeInOut(duration: 0.5)) {
            showList = true
        }
        
        print("🎉 Loading animation complete!")
    }
}

// MARK: - Enhanced Mode Toggle View

struct ModeToggleView: View {
    @Binding var isPaginationMode: Bool
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            modeLabel
            Spacer()
            toggleButtons
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var modeLabel: some View {
        HStack {
            Image(systemName: "eye.fill")
                .foregroundColor(.white.opacity(0.9))
            Text("View Mode")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
        }
    }
    
    private var toggleButtons: some View {
        HStack(spacing: 0) {
            infiniteButton
            pagesButton
        }
        .background(Color.white.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var infiniteButton: some View {
        Button(action: {
            if isPaginationMode {
                isPaginationMode = false
                onToggle()
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.system(size: 12, weight: .medium))
                Text("Infinite")
                    .font(.system(size: 8, weight: .bold))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background {
                if !isPaginationMode {  // Fixed: was isPaginationMode
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                } else {
                    Color.clear
                }
            }
            .foregroundColor(isPaginationMode ? .white.opacity(0.7) : .white)
        }
    }
    
    private var pagesButton: some View {
        Button(action: {
            if !isPaginationMode {
                isPaginationMode = true
                onToggle()
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: "doc.plaintext.fill")
                    .font(.system(size: 12, weight: .medium))
                Text("Pages")
                    .font(.system(size: 10, weight: .bold))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background {
                if isPaginationMode {  // Fixed: was !isPaginationMode
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                } else {
                    Color.clear
                }
            }
            .foregroundColor(isPaginationMode ? .white : .white.opacity(0.7))  // Fixed: swapped conditions
        }
    }
}

// MARK: - Enhanced Pagination Controls View

struct PaginationControlsView: View {
    @ObservedObject var viewModel: PokemonViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            pageIndicator
            navigationButtons
            
            if viewModel.isLoading {
                loadingIndicator
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    private var pageIndicator: some View {
        HStack {
            Image(systemName: "book.fill")
                .foregroundColor(.white.opacity(0.8))
            Text("Page \(viewModel.currentPage) of \(viewModel.totalPages > 0 ? "\(viewModel.totalPages)" : "?")")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.1))
        .cornerRadius(20)
    }
    
    private var navigationButtons: some View {
        HStack(spacing: 20) {
            previousButton
            nextButton
        }
    }
    
    private var previousButton: some View {
        Button(action: {
            Task {
                await viewModel.goToPreviousPage()
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: "arrowtriangle.left.fill")
                    .font(.system(size: 14, weight: .bold))
                Text("Previous")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(buttonBackground(enabled: viewModel.canGoPrevious, color: .red))
            .cornerRadius(25)
            .shadow(
                color: viewModel.canGoPrevious ? .red.opacity(0.4) : .clear,
                radius: 6, x: 0, y: 3
            )
        }
        .disabled(!viewModel.canGoPrevious)
        .scaleEffect(viewModel.canGoPrevious ? 1.0 : 0.95)
        .opacity(viewModel.canGoPrevious ? 1.0 : 0.6)
    }
    
    private var nextButton: some View {
        Button(action: {
            Task {
                await viewModel.goToNextPage()
            }
        }) {
            HStack(spacing: 8) {
                Text("Next")
                    .font(.system(size: 16, weight: .bold))
                Image(systemName: "arrowtriangle.right.fill")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(buttonBackground(enabled: viewModel.canGoNext, color: .blue))
            .cornerRadius(25)
            .shadow(
                color: viewModel.canGoNext ? .blue.opacity(0.4) : .clear,
                radius: 6, x: 0, y: 3
            )
        }
        .disabled(!viewModel.canGoNext)
        .scaleEffect(viewModel.canGoNext ? 1.0 : 0.95)
        .opacity(viewModel.canGoNext ? 1.0 : 0.6)
    }
    
    private func buttonBackground(enabled: Bool, color: Color) -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: enabled ?
                [color.opacity(0.8), color] :
                [Color.gray.opacity(0.3), Color.gray.opacity(0.5)]
            ),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var loadingIndicator: some View {
        HStack(spacing: 10) {
            ProgressView()
                .scaleEffect(0.8)
                .tint(.white)
            Text("Loading page...")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Enhanced Infinite Scroll Controls View

struct InfiniteScrollControlsView: View {
    @ObservedObject var viewModel: PokemonViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            if viewModel.isLoadingMore {
                loadingMoreView
            } else if !viewModel.hasMoreData {
                completionView
            }
        }
        .padding(.bottom, 20)
    }
    
    private var loadingMoreView: some View {
        HStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.0)
                .tint(.white)
            Text("Catching more Pokémon...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.1))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 20)
    }
    
    private var completionView: some View {
        VStack(spacing: 8) {
            Text("🎉")
                .font(.system(size: 32))
            Text("You've caught them all!")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
            Text("Master Trainer Achievement Unlocked!")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(completionBackground)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
        .padding(.horizontal, 20)
    }
    
    private var completionBackground: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color.yellow.opacity(0.2), Color.orange.opacity(0.1)]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

// MARK: - Enhanced Pokemon Card View

struct PokemonCardView: View {
    let pokemon: PokemonListEntry
    let onTap: (() -> Void)?
    @State private var isPressed = false
    init(pokemon: PokemonListEntry, onTap: (() -> Void)? = nil) {
            self.pokemon = pokemon
            self.onTap = onTap
        }
    var body: some View {
        VStack(spacing: 12) {
            pokemonImageView
            pokemonInfoView
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .background(cardBackground)
        .cornerRadius(20)
        .overlay(cardBorder)
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isPressed)
        
    }
    
    private var pokemonImageView: some View {
        ZStack {
            Circle()
                .fill(glowGradient)
                .frame(width: 120, height: 120)
            
            CachedAsyncImage(url: pokemon.imageURL) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            } placeholder: {
                placeholderView
            }
        }
    }
    
    private var glowGradient: RadialGradient {
        RadialGradient(
            gradient: Gradient(colors: [
                Color.white.opacity(0.3),
                Color.white.opacity(0.1),
                Color.clear
            ]),
            center: .center,
            startRadius: 30,
            endRadius: 80
        )
    }
    
    private var placeholderView: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 100, height: 100)
            
            VStack(spacing: 6) {
                ProgressView()
                    .scaleEffect(0.8)
                    .tint(.white)
                Text("Loading...")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
    
    private var pokemonInfoView: some View {
        VStack(spacing: 6) {
            Text(pokemon.name.capitalized)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                .lineLimit(1)
            
            HStack {
                Text("#\(pokemon.id)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(8)
            }
        }
    }
    
    private var cardBackground: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.white.opacity(0.25),
                Color.white.opacity(0.15)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 20)
            .stroke(Color.white.opacity(0.3), lineWidth: 1)
    }
}

// MARK: - Load More View (Legacy - kept for compatibility)

struct LoadMoreView: View {
    @ObservedObject var viewModel: PokemonViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            if viewModel.isLoadingMore {
                loadingView
            } else if viewModel.canLoadMore {
                loadMoreButton
            } else if !viewModel.hasMoreData {
                completionText
            }
        }
        .gridCellColumns(2)
    }
    
    private var loadingView: some View {
        HStack(spacing: 8) {
            ProgressView()
                .scaleEffect(0.8)
            Text("Loading more Pokémon...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    private var loadMoreButton: some View {
        Button(action: {
            Task {
                await viewModel.loadMorePokemons()
            }
        }) {
            HStack {
                Image(systemName: "arrow.down.circle")
                Text("Load More")
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
        }
    }
    
    private var completionText: some View {
        Text("You've caught them all! 🎉")
            .font(.caption)
            .foregroundColor(.secondary)
            .padding()
    }
}

// MARK: - Enhanced Loading Pokeball View

struct LoadingPokeballView: View {
    @State private var innerRotation: Double = 0
    
    var body: some View {
        ZStack {
            outerGlowRing
            mainPokeball
        }
        .onAppear {
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                innerRotation = 360
            }
        }
    }
    
    private var outerGlowRing: some View {
        Circle()
            .stroke(glowGradient, lineWidth: 4)
            .frame(width: 140, height: 140)
            .rotationEffect(.degrees(innerRotation))
    }
    
    private var glowGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.white.opacity(0.3),
                Color.blue.opacity(0.2),
                Color.red.opacity(0.2),
                Color.white.opacity(0.3)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var mainPokeball: some View {
        ZStack {
            baseCircle
            topRedSection
            blackDivider
            centerButtonOuter
            centerButtonInner
            highlightEffect
        }
    }
    
    private var baseCircle: some View {
        Circle()
            .fill(Color.white)
            .frame(width: 120, height: 120)
            .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 6)
    }
    
    private var topRedSection: some View {
        Circle()
            .fill(Color.red)
            .frame(width: 120, height: 120)
            .mask(
                Rectangle()
                    .frame(width: 120, height: 60)
                    .offset(y: -30)
            )
    }
    
    private var blackDivider: some View {
        Rectangle()
            .fill(Color.black)
            .frame(width: 120, height: 6)
    }
    
    private var centerButtonOuter: some View {
        Circle()
            .fill(Color.black)
            .frame(width: 36, height: 36)
    }
    
    private var centerButtonInner: some View {
        Circle()
            .fill(Color.white)
            .frame(width: 26, height: 26)
    }
    
    private var highlightEffect: some View {
        Circle()
            .fill(highlightGradient)
            .frame(width: 120, height: 120)
    }
    
    private var highlightGradient: RadialGradient {
        RadialGradient(
            gradient: Gradient(colors: [
                Color.white.opacity(0.4),
                Color.clear
            ]),
            center: UnitPoint(x: 0.3, y: 0.3),
            startRadius: 10,
            endRadius: 60
        )
    }
}
