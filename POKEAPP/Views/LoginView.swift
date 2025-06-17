//
//  LoginView.swift
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
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    private var isIPad: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .regular
    }
    
    private var isLandscape: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .compact
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient using tokens
                PokemonTheme.primaryGradient
                    .ignoresSafeArea()
                
                // Floating Pokeball decorations using tokens
                decorativeElements
                
                // Main content with responsive layout
                if isLandscape {
                    landscapeLayout
                } else {
                    portraitLayout
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Ensures single view on iPad
    }
    
    // MARK: - Layout Variants
    
    private var portraitLayout: some View {
        VStack(spacing: isIPad ? SpacingToken.xxl.value : SpacingToken.xl.value) {
            // Pokemon Logo Area
            logoSection
            
            // Login Form - constrained width on iPad
            loginForm
                .frame(maxWidth: isIPad ? 500 : .infinity)
            
            Spacer()
        }
        .padding(.top, isIPad ? SpacingToken.xxxl.value * 1.5 : SpacingToken.xxxl.value)
        .padding(.horizontal, isIPad ? SpacingToken.xxl.value : SpacingToken.lg.value)
    }
    
    private var landscapeLayout: some View {
        HStack(spacing: SpacingToken.xxxl.value) {
            // Left side - Logo
            VStack {
                logoSection
                Spacer()
            }
            .frame(maxWidth: .infinity)
            
            // Right side - Form
            VStack {
                loginForm
                    .frame(maxWidth: 400)
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, SpacingToken.xxl.value)
        .padding(.vertical, SpacingToken.xl.value)
    }
    
    // MARK: - View Components
    
    private var decorativeElements: some View {
        GeometryReader { geometry in
            // Adjust decorative elements for different screen sizes
            let circleSize1 = isIPad ? 150 : 100
            let circleSize2 = isIPad ? 90 : 60
            let circleSize3 = isIPad ? 120 : 80
            
            Circle()
                .fill(Color.token(.textOnDark).opacity(OpacityToken.light.value))
                .frame(width: CGFloat(circleSize1), height: CGFloat(circleSize1))
                .position(x: geometry.size.width * 0.15, y: geometry.size.height * 0.2)
            
            Circle()
                .fill(Color.token(.textOnDark).opacity(0.08))
                .frame(width: CGFloat(circleSize2), height: CGFloat(circleSize2))
                .position(x: geometry.size.width * 0.85, y: geometry.size.height * 0.15)
            
            Circle()
                .fill(Color.token(.textOnDark).opacity(0.06))
                .frame(width: CGFloat(circleSize3), height: CGFloat(circleSize3))
                .position(x: geometry.size.width * 0.9, y: geometry.size.height * 0.7)
                
            // Additional decorative elements for iPad
            if isIPad {
                Circle()
                    .fill(Color.token(.textOnDark).opacity(0.04))
                    .frame(width: 200, height: 200)
                    .position(x: geometry.size.width * 0.1, y: geometry.size.height * 0.8)
                
                Circle()
                    .fill(Color.token(.textOnDark).opacity(0.05))
                    .frame(width: 100, height: 100)
                    .position(x: geometry.size.width * 0.75, y: geometry.size.height * 0.85)
            }
        }
    }
    
    private var logoSection: some View {
        VStack(spacing: SpacingToken.xs.value) {
            // Pokeball Icon using tokens - larger on iPad
            pokeballIcon
            
            Text("PokéExplorer")
                .font(isIPad ? .token(.displayLarge) : .token(.displayMedium))
                .foregroundColor(.token(.textOnDark))
                .shadow(.md)
        }
        .padding(.bottom, SpacingToken.lg.value)
    }
    
    private var pokeballIcon: some View {
        let iconSize: CGFloat = isIPad ? 120 : 80
        let centerButtonSize: CGFloat = isIPad ? 30 : 20
        let centerLineHeight: CGFloat = isIPad ? 4 : 3
        
        return ZStack {
            Circle()
                .fill(Color.token(.textOnDark))
                .frame(width: iconSize, height: iconSize)
                .shadow(.lg)
            
            // Top red semicircle
            Circle()
                .fill(Color.token(.pokemonRed))
                .frame(width: iconSize, height: iconSize)
                .mask(
                    Rectangle()
                        .frame(width: iconSize, height: iconSize/2)
                        .offset(y: -iconSize/4)
                )
            
            // Black center line
            Rectangle()
                .fill(Color.token(.textOnLight))
                .frame(width: iconSize, height: centerLineHeight)
            
            // Center button
            Circle()
                .fill(Color.token(.textOnDark))
                .frame(width: centerButtonSize, height: centerButtonSize)
                .overlay(
                    Circle()
                        .stroke(Color.token(.textOnLight), lineWidth: isIPad ? 3 : 2)
                )
        }
    }
    
    private var loginForm: some View {
        VStack(spacing: isIPad ? SpacingToken.lg.value : SpacingToken.md.value) {
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
        .padding(.horizontal, isIPad ? SpacingToken.xl.value : SpacingToken.lg.value)
    }
    
    private var emailField: some View {
        VStack(alignment: .leading, spacing: SpacingToken.xs.value) {
            HStack {
                Image(systemName: "envelope.fill")
                    .foregroundColor(.token(.pokemonYellow))
                    .iconSize(isIPad ? .lg : .sm)
                Text("Email")
                    .font(isIPad ? .token(.titleMedium) : .token(.titleSmall))
                    .foregroundColor(.token(.textOnDark))
            }
            
            TextField("Digite seu email", text: $email)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(isIPad ? .token(.bodyLarge) : .token(.bodyMedium))
                .padding(.horizontal, isIPad ? SpacingToken.lg : SpacingToken.md)
                .padding(.vertical, isIPad ? SpacingToken.md : SpacingToken.sm)
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
                    .iconSize(isIPad ? .lg : .sm)
                Text("Senha")
                    .font(isIPad ? .token(.titleMedium) : .token(.titleSmall))
                    .foregroundColor(.token(.textOnDark))
            }
            
            SecureField("Digite sua senha", text: $senha)
                .font(isIPad ? .token(.bodyLarge) : .token(.bodyMedium))
                .padding(.horizontal, isIPad ? SpacingToken.lg : SpacingToken.md)
                .padding(.vertical, isIPad ? SpacingToken.md : SpacingToken.sm)
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
                    .iconSize(isIPad ? .lg : .sm)
                Text("ENTRAR")
                    .font(isIPad ? .token(.titleLarge) : .token(.titleMedium))
                    .foregroundColor(.token(.textOnDark))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, isIPad ? SpacingToken.md : SpacingToken.sm)
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
                .iconSize(isIPad ? .md : .sm)
            Text(errorMessage)
                .font(isIPad ? .token(.bodyMedium) : .token(.bodySmall))
                .foregroundColor(.token(.error))
        }
        .padding(.horizontal, isIPad ? SpacingToken.lg : SpacingToken.md)
        .padding(.vertical, isIPad ? SpacingToken.sm : SpacingToken.xs)
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
                        .iconSize(isIPad ? .lg : .sm)
                    Text("CRIAR CONTA")
                        .font(isIPad ? .token(.titleLarge) : .token(.titleMedium))
                        .foregroundColor(.token(.textOnDark))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, isIPad ? SpacingToken.md : SpacingToken.sm)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: BorderRadiusToken.full.value)
                        .stroke(Color.token(.textOnDark), lineWidth: isIPad ? 3 : 2)
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
