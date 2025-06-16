//
//  RegisterView.swift
//  POKEAPP
//
//  Created by João Vitor De Freitas, Carlos Hobmeier, Amanda Queiroz e Theo Nicoleli on 12/06/25.
//

import SwiftUI

struct MainAppView: View {
    @ObservedObject var auth: AuthViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.2, green: 0.6, blue: 1.0),
                        Color(red: 0.1, green: 0.4, blue: 0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Floating Pokeball decorations
                GeometryReader { geometry in
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 120, height: 120)
                        .position(x: geometry.size.width * 0.15, y: geometry.size.height * 0.25)
                    
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 80, height: 80)
                        .position(x: geometry.size.width * 0.85, y: geometry.size.height * 0.2)
                    
                    Circle()
                        .fill(Color.white.opacity(0.06))
                        .frame(width: 100, height: 100)
                        .position(x: geometry.size.width * 0.9, y: geometry.size.height * 0.75)
                    
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 60, height: 60)
                        .position(x: geometry.size.width * 0.1, y: geometry.size.height * 0.8)
                }
                
                VStack(spacing: 32) {
                    // Pokemon Header
                    VStack(spacing: 12) {
                        // Master Ball Icon
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 90, height: 90)
                                .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)
                            
                            // Purple top semicircle
                            Circle()
                                .fill(Color.purple)
                                .frame(width: 90, height: 90)
                                .mask(
                                    Rectangle()
                                        .frame(width: 90, height: 45)
                                        .offset(y: -22.5)
                                )
                            
                            // Pink accent line
                            Rectangle()
                                .fill(Color.pink)
                                .frame(width: 90, height: 4)
                                .offset(y: -10)
                            
                            // Black center line
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: 90, height: 3)
                            
                            // Center button with M
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.black, lineWidth: 2)
                                    )
                                
                                Text("M")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.purple)
                            }
                        }
                        
                        Text("PokéExplorer")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
                        
                        Text("Bem-vindo, Treinador!")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                    }
                    .padding(.top, 40)
                    
                    // Menu Options
                    VStack(spacing: 20) {
                        // Pokédex Button
                        NavigationLink(destination: PokemonListView()) {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 50, height: 50)
                                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                    
                                    Image(systemName: "book.fill")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Pokédex")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.primary)
                                    
                                    Text("Explore todos os Pokémon")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 18)
                            .background(Color.white.opacity(0.95))
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Favorites Button - Fixed with safe unwrapping
                        if let currentUser = auth.currentUser {
                            NavigationLink(destination: ListaFavoritosView(usuario: currentUser)) {
                                HStack(spacing: 16) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.yellow)
                                            .frame(width: 50, height: 50)
                                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                        
                                        Image(systemName: "heart.fill")
                                            .font(.system(size: 22, weight: .bold))
                                            .foregroundColor(.red)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Meus Favoritos")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(.primary)
                                        
                                        Text("Seus Pokémon preferidos")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 18)
                                .background(Color.white.opacity(0.95))
                                .cornerRadius(20)
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        // Logout Button
                        Button(action: {
                            auth.logout()
                        }) {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color.red.opacity(0.9))
                                        .frame(width: 50, height: 50)
                                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                    
                                    Image(systemName: "power")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Logout")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.red)
                                    
                                    Text("Sair da conta")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.red.opacity(0.7))
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 18)
                            .background(Color.white.opacity(0.95))
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    // Footer
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(.yellow)
                            Text("Gotta Catch 'Em All!")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            Image(systemName: "sparkles")
                                .foregroundColor(.yellow)
                        }
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                        
                        Text("© 2025 PokéExplorer. All rights reserved.")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}
