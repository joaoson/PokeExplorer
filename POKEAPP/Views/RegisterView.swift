//
//  RegisterView.swift
//  POKEAPP
//
//  Created by João Vitor De Freitas, Carlos Hobmeier, Amanda Queiroz e Theo Nicoleli on 10/06/25.
//

import SwiftUI

struct RegisterView: View {
    @ObservedObject var auth: AuthViewModel

    @State private var nome = ""
    @State private var email = ""
    @State private var senha = ""
    @State private var errorMessage = ""

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            PokemonTheme.dangerGradient
                .ignoresSafeArea()
            
            GeometryReader { geometry in
                Circle()
                    .fill(Color.token(.textOnDark))
                    .opacity(OpacityToken.light.value)
                    .frame(width: 120, height: 120)
                    .position(x: geometry.size.width * 0.85, y: geometry.size.height * 0.2)
                
                Circle()
                    .fill(Color.token(.ultraBallYellow))
                    .opacity(OpacityToken.light.value)
                    .frame(width: 80, height: 80)
                    .position(x: geometry.size.width * 0.1, y: geometry.size.height * 0.3)
                
                Circle()
                    .fill(Color.token(.masterBallPurple))
                    .opacity(OpacityToken.light.value)
                    .frame(width: 90, height: 90)
                    .position(x: geometry.size.width * 0.9, y: geometry.size.height * 0.8)
            }
            
            ScrollView {
                VStack(spacing: SpacingToken.xl.value) {
                    // Header with Pokemon theme
                    VStack(spacing: SpacingToken.sm.value) {
                        // Great Ball Icon
                        ZStack {
                            Circle()
                                .fill(Color.token(.textOnDark))
                                .frame(width: 80, height: 80)
                                .shadow(.lg)
                            
                            Circle()
                                .fill(Color.token(.greatBallBlue))
                                .frame(width: 80, height: 80)
                                .mask(
                                    Rectangle()
                                        .frame(width: 80, height: 40)
                                        .offset(y: -20)
                                )
                            
                            Circle()
                                .fill(Color.token(.pokemonRed))
                                .frame(width: 80, height: 80)
                                .mask(
                                    Rectangle()
                                        .frame(width: 80, height: 40)
                                        .offset(y: 20)
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
                        
                        Text("Novo Treinador")
                            .font(.token(.displayMedium))
                            .foregroundColor(.token(.textOnDark))
                            .shadow(.sm)
                        
                        Text("Comece sua jornada Pokemon!")
                            .font(.token(.bodyLarge))
                            .foregroundColor(Color.token(.textOnDark))
                            .opacity(OpacityToken.strong.value)
                    }
                    .padding(.top, SpacingToken.xxxl.value)
                    .padding(.bottom, SpacingToken.lg.value)
                    
                    // Registration Form
                    VStack(spacing: SpacingToken.lg.value) {
                        // Name Field
                        VStack(alignment: .leading, spacing: SpacingToken.xs.value) {
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(.token(.pokemonYellow))
                                    .iconSize(.sm)
                                Text("Nome de Treinador")
                                    .font(.token(.titleSmall))
                                    .foregroundColor(.token(.textOnDark))
                            }
                            
                            TextField("Como você quer ser chamado?", text: $nome)
                                .padding(.horizontal, SpacingToken.md.value)
                                .padding(.vertical, SpacingToken.sm.value)
                                .background(ComponentStyleToken.TextField.backgroundColor)
                                .cornerRadius(.full)
                                .shadow(.sm)
                                .overlay(
                                    RoundedRectangle(cornerRadius: BorderRadiusToken.full.value)
                                        .stroke(getFieldBorderColor(for: .name), lineWidth: 2)
                                )
                            
                            // Name validation message
                            if !nome.isEmpty && !isValidName(nome) {
                                ValidationMessageView(
                                    message: "Nome deve ter entre 2-20 caracteres, apenas letras e espaços",
                                    isError: true
                                )
                                .transition(.opacity)
                            }
                        }
                        
                        // Email Field
                        VStack(alignment: .leading, spacing: SpacingToken.xs.value) {
                            HStack {
                                Image(systemName: "envelope.circle.fill")
                                    .foregroundColor(.token(.pokemonYellow))
                                    .iconSize(.sm)
                                Text("Email")
                                    .font(.token(.titleSmall))
                                    .foregroundColor(.token(.textOnDark))
                            }
                            
                            TextField("Digite seu melhor email", text: $email)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .keyboardType(.emailAddress)
                                .padding(.horizontal, SpacingToken.md.value)
                                .padding(.vertical, SpacingToken.sm.value)
                                .background(ComponentStyleToken.TextField.backgroundColor)
                                .cornerRadius(.full)
                                .shadow(.sm)
                                .overlay(
                                    RoundedRectangle(cornerRadius: BorderRadiusToken.full.value)
                                        .stroke(getFieldBorderColor(for: .email), lineWidth: 2)
                                )
                            
                            // Email validation message
                            if !email.isEmpty && !isValidEmail(email) {
                                ValidationMessageView(
                                    message: "Por favor, digite um email válido",
                                    isError: true
                                )
                                .transition(.opacity)
                            }
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: SpacingToken.xs.value) {
                            HStack {
                                Image(systemName: "lock.circle.fill")
                                    .foregroundColor(.token(.pokemonYellow))
                                    .iconSize(.sm)
                                Text("Senha Secreta")
                                    .font(.token(.titleSmall))
                                    .foregroundColor(.token(.textOnDark))
                            }
                            
                            SecureField("Mínimo 8 caracteres", text: $senha)
                                .padding(.horizontal, SpacingToken.md.value)
                                .padding(.vertical, SpacingToken.sm.value)
                                .background(ComponentStyleToken.TextField.backgroundColor)
                                .cornerRadius(.full)
                                .shadow(.sm)
                                .overlay(
                                    RoundedRectangle(cornerRadius: BorderRadiusToken.full.value)
                                        .stroke(getFieldBorderColor(for: .password), lineWidth: 2)
                                )
                            
                            // Password strength indicator
                            if !senha.isEmpty {
                                VStack(alignment: .leading, spacing: SpacingToken.xxs.value) {
                                    HStack {
                                        Text("Força da senha:")
                                            .font(.token(.caption))
                                            .foregroundColor(Color.token(.textOnDark))
                                            .opacity(OpacityToken.strong.value)
                                        
                                        Text(getPasswordStrengthText())
                                            .font(.token(.caption))
                                            .fontWeight(.bold)
                                            .foregroundColor(getPasswordStrengthColor())
                                    }
                                    
                                    // Password requirements
                                    VStack(alignment: .leading, spacing: 2) {
                                        PasswordRequirementRow(
                                            text: "Pelo menos 8 caracteres",
                                            isValid: senha.count >= 8
                                        )
                                        PasswordRequirementRow(
                                            text: "Contém letra maiúscula",
                                            isValid: senha.range(of: "[A-Z]", options: .regularExpression) != nil
                                        )
                                        PasswordRequirementRow(
                                            text: "Contém letra minúscula",
                                            isValid: senha.range(of: "[a-z]", options: .regularExpression) != nil
                                        )
                                        PasswordRequirementRow(
                                            text: "Contém número",
                                            isValid: senha.range(of: "[0-9]", options: .regularExpression) != nil
                                        )
                                        PasswordRequirementRow(
                                            text: "Contém caractere especial",
                                            isValid: senha.range(of: "[!@#$%^&*(),.?\":{}|<>]", options: .regularExpression) != nil
                                        )
                                    }
                                }
                                .padding(.horizontal, SpacingToken.xs.value)
                                .transition(.opacity)
                            }
                        }
                        
                        // Register Button
                        Button(action: {
                            registerUser()
                        }) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.token(.textOnDark))
                                    .iconSize(.sm)
                                Text("COMEÇAR AVENTURA")
                                    .font(.token(.labelLarge))
                                    .fontWeight(.bold)
                                    .foregroundColor(.token(.textOnDark))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, SpacingToken.md.value)
                            .background(PokemonTheme.secondaryGradient)
                            .cornerRadius(.full)
                            .shadow(.lg)
                            .scaleEffect(isFormValid() ? 1.0 : 0.95)
                            .animation(.spring, value: isFormValid())
                        }
                        .disabled(!isFormValid())
                        .opacity(isFormValid() ? OpacityToken.opaque.value : OpacityToken.strong.value)
                        
                        // Error Message
                        if !errorMessage.isEmpty {
                            ErrorMessageView(message: errorMessage)
                                .transition(.scale.combined(with: .opacity))
                        }
                        
                        // Back to Login hint
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Image(systemName: "arrow.left.circle")
                                    .foregroundColor(Color.token(.textOnDark))
                                    .opacity(OpacityToken.strong.value)
                                    .iconSize(.sm)
                                Text("Já tem uma conta? Voltar ao login")
                                    .font(.token(.bodyMedium))
                                    .foregroundColor(Color.token(.textOnDark))
                                    .opacity(OpacityToken.strong.value)
                            }
                        }
                        .padding(.top, SpacingToken.xs.value)
                    }
                    .padding(.horizontal, SpacingToken.xl.value)
                    
                    Spacer(minLength: SpacingToken.xxxl.value)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.token(.textOnDark))
                            .iconSize(.sm)
                        Text("Voltar")
                            .foregroundColor(.token(.textOnDark))
                            .font(.token(.bodyMedium))
                    }
                }
            }
        }
    }
    
    // MARK: - Validation Functions
    
    private enum FieldType {
        case name, email, password
    }
    
    private func getFieldBorderColor(for field: FieldType) -> Color {
        switch field {
        case .name:
            if nome.isEmpty { return Color.clear }
            return isValidName(nome) ? Color.token(.success) : Color.token(.error)
        case .email:
            if email.isEmpty { return Color.clear }
            return isValidEmail(email) ? Color.token(.success) : Color.token(.error)
        case .password:
            if senha.isEmpty { return Color.clear }
            return isStrongPassword(senha) ? Color.token(.success) : (senha.count >= 8 ? Color.token(.warning) : Color.token(.error))
        }
    }
    
    private func isValidName(_ name: String) -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        // Nome deve ter entre 2-20 caracteres, apenas letras, espaços e acentos
        let nameRegex = "^[a-zA-ZÀ-ÿ\\s]{2,20}$"
        let namePredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        return namePredicate.evaluate(with: trimmedName) && !trimmedName.isEmpty
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func isStrongPassword(_ password: String) -> Bool {
        // Senha forte: pelo menos 8 caracteres, maiúscula, minúscula, número e caractere especial
        let length = password.count >= 8
        let hasUppercase = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let hasLowercase = password.range(of: "[a-z]", options: .regularExpression) != nil
        let hasNumber = password.range(of: "[0-9]", options: .regularExpression) != nil
        let hasSpecialChar = password.range(of: "[!@#$%^&*(),.?\":{}|<>]", options: .regularExpression) != nil
        
        return length && hasUppercase && hasLowercase && hasNumber && hasSpecialChar
    }
    
    private func getPasswordStrength(_ password: String) -> Int {
        var strength = 0
        
        if password.count >= 8 { strength += 1 }
        if password.range(of: "[A-Z]", options: .regularExpression) != nil { strength += 1 }
        if password.range(of: "[a-z]", options: .regularExpression) != nil { strength += 1 }
        if password.range(of: "[0-9]", options: .regularExpression) != nil { strength += 1 }
        if password.range(of: "[!@#$%^&*(),.?\":{}|<>]", options: .regularExpression) != nil { strength += 1 }
        
        return strength
    }
    
    private func getPasswordStrengthText() -> String {
        let strength = getPasswordStrength(senha)
        switch strength {
        case 0...1: return "Muito Fraca"
        case 2: return "Fraca"
        case 3: return "Média"
        case 4: return "Forte"
        case 5: return "Muito Forte"
        default: return "Muito Fraca"
        }
    }
    
    private func getPasswordStrengthColor() -> Color {
        let strength = getPasswordStrength(senha)
        switch strength {
        case 0...1: return Color.token(.error)
        case 2: return Color.token(.warning)
        case 3: return Color.token(.pokemonYellow)
        case 4: return Color.token(.success)
        case 5: return Color.token(.success)
        default: return Color.token(.error)
        }
    }
    
    private func isFormValid() -> Bool {
        return isValidName(nome) && isValidEmail(email) && senha.count >= 8
    }
    
    private func registerUser() {
        // Limpar mensagem de erro anterior
        errorMessage = ""
        
        // Validações finais
        guard isValidName(nome) else {
            errorMessage = "Nome inválido. Use apenas letras e espaços (2-20 caracteres)."
            return
        }
        
        guard isValidEmail(email) else {
            errorMessage = "Por favor, digite um email válido."
            return
        }
        
        guard senha.count >= 8 else {
            errorMessage = "A senha deve ter pelo menos 8 caracteres."
            return
        }
        
        // Se chegou até aqui, todos os dados são válidos
        if auth.register(nomeDeUsuario: nome.trimmingCharacters(in: .whitespacesAndNewlines),
                        email: email.lowercased().trimmingCharacters(in: .whitespacesAndNewlines),
                        senha: senha) {
            presentationMode.wrappedValue.dismiss()
        } else {
            errorMessage = "Erro ao criar conta. Tente novamente."
        }
    }
}

// MARK: - Supporting Components

struct ValidationMessageView: View {
    let message: String
    let isError: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(isError ? Color.token(.warning) : Color.token(.info))
                .iconSize(.xs)
            Text(message)
                .font(.token(.caption))
                .foregroundColor(isError ? Color.token(.warning) : Color.token(.info))
        }
    }
}

struct ErrorMessageView: View {
    let message: String
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.token(.warning))
                .iconSize(.sm)
            Text(message)
                .font(.token(.bodyMedium))
                .foregroundColor(.token(.textOnDark))
        }
        .padding(.horizontal, SpacingToken.md.value)
        .padding(.vertical, SpacingToken.xs.value)
        .background(Color.token(.error))
        .opacity(OpacityToken.light.value)
        .overlay(
            RoundedRectangle(cornerRadius: BorderRadiusToken.md.value)
                .stroke(Color.token(.warning), lineWidth: 1)
        )
        .cornerRadius(.md)
    }
}

// MARK: - Password Requirement Row Component
struct PasswordRequirementRow: View {
    let text: String
    let isValid: Bool
    
    var body: some View {
        HStack(spacing: SpacingToken.xxs.value) {
            Image(systemName: isValid ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isValid ? Color.token(.success) : Color.token(.textOnDark))
                .opacity(isValid ? OpacityToken.opaque.value : OpacityToken.medium.value)
                .iconSize(.xs)
            
            Text(text)
                .font(.token(.overline))
                .foregroundColor(isValid ? Color.token(.success) : Color.token(.textOnDark))
                .opacity(isValid ? OpacityToken.opaque.value : OpacityToken.strong.value)
        }
    }
}
