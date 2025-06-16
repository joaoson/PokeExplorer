//
//  RegisterView.swift
//  POKEAPP
//
//  Created by João Vitor De Freitas, Carlos Hobmeier, Amanda Queiroz e Theo Nicoleli on 10/06/25.
//

import Foundation

@MainActor
class PokemonViewModel: ObservableObject {
    @Published var pokemons: [PokemonListEntry] = []
    @Published var favorites: Set<Int> = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var hasMoreData = true
    
    @Published var currentPage = 1
    @Published var totalPages = 0
    @Published var canGoPrevious = false
    @Published var canGoNext = true
    @Published var isPaginationMode = false
    
    private let pageSize = 20
    private var currentOffset = 0
    private var totalCount = 0
    
    // MARK: - Initial Load
    func loadPokemons() async {
        guard !isLoading else { return }
        
        isLoading = true
        currentOffset = 0
        currentPage = 1
        pokemons = []
        hasMoreData = true
        
        do {
            let response = try await PokeAPIService.shared.fetchPokemonList(
                limit: pageSize,
                offset: currentOffset
            )
            
            pokemons = response.results
            totalCount = response.count
            currentOffset = pageSize
            hasMoreData = response.next != nil
            
            totalPages = (totalCount + pageSize - 1) / pageSize // Ceiling division
            updatePaginationState()
            
            print("✅ Initial load complete: \(pokemons.count) Pokemon loaded")
            
        } catch {
            print("❌ Error loading Pokemon: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Load More Data (Infinite Scroll)
    func loadMorePokemons() async {
        guard !isLoadingMore && !isLoading && hasMoreData && !isPaginationMode else { return }
        
        isLoadingMore = true
        
        do {
            let response = try await PokeAPIService.shared.fetchPokemonList(
                limit: pageSize,
                offset: currentOffset
            )
            
            pokemons.append(contentsOf: response.results)
            currentOffset += pageSize
            hasMoreData = response.next != nil
            
            print("✅ Load more complete: \(response.results.count) new Pokemon loaded. Total: \(pokemons.count)")
            
        } catch {
            print("❌ Error loading more Pokemon: \(error)")
        }
        
        isLoadingMore = false
    }
    
    // MARK: - Pagination Methods
    
    func switchMode(toPagination: Bool) async {
        isPaginationMode = toPagination
        
        if toPagination {
            currentPage = 1
            await loadPage(page: 1)
        } else {
            // Switching to infinite scroll - reload from beginning
            await loadPokemons()
        }
    }
    
    func goToNextPage() async {
        guard canGoNext && !isLoading else { return }
        
        let nextPage = currentPage + 1
        await loadPage(page: nextPage)
    }
    
    func goToPreviousPage() async {
        guard canGoPrevious && !isLoading && currentPage > 1 else { return }
        
        let previousPage = currentPage - 1
        await loadPage(page: previousPage)
    }
    
    private func loadPage(page: Int) async {
        guard !isLoading else { return }
        
        isLoading = true
        
        let offset = (page - 1) * pageSize
        
        do {
            let response = try await PokeAPIService.shared.fetchPokemonList(
                limit: pageSize,
                offset: offset
            )
            
            pokemons = response.results
            currentPage = page
            currentOffset = offset + pageSize
            totalCount = response.count
            totalPages = (totalCount + pageSize - 1) / pageSize
            hasMoreData = response.next != nil
            
            updatePaginationState()
            
            print("✅ Page \(page) loaded: \(pokemons.count) Pokemon")
            
        } catch {
            print("❌ Error loading page \(page): \(error)")
        }
        
        isLoading = false
    }
    
    private func updatePaginationState() {
        canGoPrevious = currentPage > 1
        canGoNext = currentPage < totalPages
    }
    
    // MARK: - Refresh Data
    func refreshPokemons() async {
        if isPaginationMode {
            await loadPage(page: currentPage)
        } else {
            await loadPokemons()
        }
    }
    
    // MARK: - Favorites Management
    func toggleFavorite(pokemon: PokemonDetail) {
        if favorites.contains(pokemon.id) {
            favorites.remove(pokemon.id)
        } else {
            favorites.insert(pokemon.id)
        }
    }
    
    func isFavorite(pokemon: PokemonDetail) -> Bool {
        favorites.contains(pokemon.id)
    }
    
    // MARK: - Utility Methods
    var loadingProgress: String {
        if totalCount > 0 {
            if isPaginationMode {
                return "Page \(currentPage) of \(totalPages)"
            } else {
                let percentage = (Double(pokemons.count) / Double(totalCount)) * 100
                return String(format: "%.0f%%", percentage)
            }
        }
        return "Loading..."
    }
    
    var canLoadMore: Bool {
        !isPaginationMode && hasMoreData && !isLoading && !isLoadingMore
    }
    
    // MARK: - Debug Information
    var debugInfo: String {
        """
        Mode: \(isPaginationMode ? "Pagination" : "Infinite Scroll")
        Current Page: \(currentPage)
        Total Pages: \(totalPages)
        Pokemon Count: \(pokemons.count)
        Total Count: \(totalCount)
        Has More Data: \(hasMoreData)
        Can Go Previous: \(canGoPrevious)
        Can Go Next: \(canGoNext)
        """
    }
}
