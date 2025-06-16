//
//  RegisterView.swift
//  POKEAPP
//
//  Created by João Vitor De Freitas, Carlos Hobmeier, Amanda Queiroz e Theo Nicoleli on 11/06/25.
//

import Foundation

class PokeAPIService: ObservableObject {
    static let shared = PokeAPIService()
    
    private let session: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30.0
        config.timeoutIntervalForResource = 60.0
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config)
    }
    
    func fetchPokemonList(limit: Int = 20, offset: Int = 0) async throws -> PokemonListResponse {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=\(limit)&offset=\(offset)") else {
            throw URLError(.badURL)
        }
        
        print("🌐 Fetching Pokemon list from: \(url.absoluteString)")
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoded = try JSONDecoder().decode(PokemonListResponse.self, from: data)
        print("✅ Successfully fetched \(decoded.results.count) Pokemon (offset: \(offset))")
        return decoded
    }
    
    func fetchPokemonDetail(name: String) async throws -> PokemonDetail {
        let pokemonIdentifier = name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(pokemonIdentifier)") else {
            throw URLError(.badURL)
        }
        
        print("🌐 Fetching Pokemon detail from: \(url.absoluteString)")
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response type")
                throw URLError(.badServerResponse)
            }
            
            print("📡 HTTP Status Code: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                print("❌ HTTP Error: \(httpResponse.statusCode)")
                throw URLError(.badServerResponse)
            }
            
            print("✅ Successfully received data: \(data.count) bytes")
            
            let decoded = try JSONDecoder().decode(PokemonDetail.self, from: data)
            print("✅ Successfully decoded Pokemon: \(decoded.name)")
            return decoded
            
        } catch {
            print("❌ Network error: \(error)")
            throw error
        }
    }
}
