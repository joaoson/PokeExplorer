//
//  RegisterView.swift
//  POKEAPP
//
//  Created by João Vitor De Freitas, Carlos Hobmeier, Amanda Queiroz e Theo Nicoleli on 11/06/25.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var auth: AuthViewModel

    @State private var email = ""
    @State private var senha = ""
    @State private var showRegister = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient using tokens
                PokemonTheme.primaryGradient
                    .ignoresSafeArea()
                
                // Floating Pokeball decorations using tokens
                decorativeElements
                
                VStack(spacing: SpacingToken.xl.value) {
                    // Pokemon Logo Area
                    logoSection
                    
                    // Login Form
                    loginForm
                    
                    Spacer()
                }
                .padding(.top, SpacingToken.xxxl.value)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - View Components
    
    private var decorativeElements: some View {
        GeometryReader { geometry in
            Circle()
                .fill(Color.token(.textOnDark).opacity(OpacityToken.light.value))
                .frame(width: 100, height: 100)
                .position(x: geometry.size.width * 0.15, y: geometry.size.height * 0.2)
            
            Circle()
                .fill(Color.token(.textOnDark).opacity(0.08))
                .frame(width: 60, height: 60)
                .position(x: geometry.size.width * 0.85, y: geometry.size.height * 0.15)
            
            Circle()
                .fill(Color.token(.textOnDark).opacity(0.06))
                .frame(width: 80, height: 80)
                .position(x: geometry.size.width * 0.9, y: geometry.size.height * 0.7)
        }
    }
    
    private var logoSection: some View {
        VStack(spacing: SpacingToken.xs.value) {
            // Pokeball Icon using tokens
            pokeballIcon
            
            Text("PokéExplorer")
                .font(.token(.displayMedium))
                .foregroundColor(.token(.textOnDark))
                .shadow(.md)
        }
        .padding(.bottom, SpacingToken.lg.value)
    }
    
    private var pokeballIcon: some View {
        ZStack {
            Circle()
                .fill(Color.token(.textOnDark))
                .frame(width: 80, height: 80)
                .shadow(.lg)
            
            // Top red semicircle
            Circle()
                .fill(Color.token(.pokemonRed))
                .frame(width: 80, height: 80)
                .mask(
                    Rectangle()
                        .frame(width: 80, height: 40)
                        .offset(y: -20)
                )
            
            // Black center line
            Rectangle()
                .fill(Color.token(.textOnLight))
                .frame(width: 80, height: 3)
            
            // Center button
            Circle()
                .fill(Color.token(.textOnDark))
                .frame(width: 20, height: 20)
                .overlay(
                    Circle()
                        .stroke(Color.token(.textOnLight), lineWidth: 2)
                )
        }
    }
    
    private var loginForm: some View {
        VStack(spacing: SpacingToken.md.value) {
            // Email Field
            emailField
            
            // Password Field
            passwordField
            
            // Login Button
            loginButton
            
            // Error Message
            if !errorMessage.isEmpty {
                errorMessageView
            }
            
            // Register Navigation
            registerButton
        }
        .padding(.horizontal, SpacingToken.lg.value)
    }
    
    private var emailField: some View {
        VStack(alignment: .leading, spacing: SpacingToken.xs.value) {
            HStack {
                Image(systemName: "envelope.fill")
                    .foregroundColor(.token(.pokemonYellow))
                    .iconSize(.sm)
                Text("Email")
                    .font(.token(.titleSmall))
                    .foregroundColor(.token(.textOnDark))
            }
            
            TextField("Digite seu email", text: $email)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(.horizontal, SpacingToken.md)
                .padding(.vertical, SpacingToken.sm)
                .background(ComponentStyleToken.TextField.backgroundColor)
                .cornerRadius(.full)
                .shadow(.sm)
        }
    }
    
    private var passwordField: some View {
        VStack(alignment: .leading, spacing: SpacingToken.xs.value) {
            HStack {
                Image(systemName: "lock.fill")
                    .foregroundColor(.token(.pokemonYellow))
                    .iconSize(.sm)
                Text("Senha")
                    .font(.token(.titleSmall))
                    .foregroundColor(.token(.textOnDark))
            }
            
            SecureField("Digite sua senha", text: $senha)
                .padding(.horizontal, SpacingToken.md)
                .padding(.vertical, SpacingToken.sm)
                .background(ComponentStyleToken.TextField.backgroundColor)
                .cornerRadius(.full)
                .shadow(.sm)
        }
    }
    
    private var loginButton: some View {
        Button(action: {
            performLogin()
        }) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.token(.textOnDark))
                    .iconSize(.sm)
                Text("ENTRAR")
                    .font(.token(.titleMedium))
                    .foregroundColor(.token(.textOnDark))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, SpacingToken.sm)
            .background(PokemonTheme.secondaryGradient)
            .cornerRadius(.full)
            .shadow(.lg)
        }
        .scaleEffect(isFormValid ? 1.0 : 0.95)
    }
    
    private var errorMessageView: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.token(.error))
                .iconSize(.sm)
            Text(errorMessage)
                .font(.token(.bodySmall))
                .foregroundColor(.token(.error))
        }
        .padding(.horizontal, SpacingToken.md)
        .padding(.vertical, SpacingToken.xs)
        .background(Color.token(.backgroundCard))
        .cornerRadius(.md)
    }
    
    private var registerButton: some View {
        NavigationLink(
            destination: RegisterView(auth: auth),
            isActive: $showRegister
        ) {
            Button(action: {
                showRegister = true
            }) {
                HStack {
                    Image(systemName: "person.badge.plus")
                        .foregroundColor(.token(.textOnDark))
                        .iconSize(.sm)
                    Text("CRIAR CONTA")
                        .font(.token(.titleMedium))
                        .foregroundColor(.token(.textOnDark))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, SpacingToken.sm)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: BorderRadiusToken.full.value)
                        .stroke(Color.token(.textOnDark), lineWidth: 2)
                )
                .cornerRadius(.full)
            }
        }
        .padding(.top, SpacingToken.xs)
    }
    
    // MARK: - Computed Properties
    
    private var isFormValid: Bool {
        !email.isEmpty && !senha.isEmpty
    }
    
    // MARK: - Actions
    
    private func performLogin() {
        if auth.login(email: email, senha: senha) {
            // Handle login success
        } else {
            errorMessage = "Email ou senha incorretos."
        }
    }
}
