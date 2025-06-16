//
//  RegisterView.swift
//  POKEAPP
//
//  Created by João Vitor De Freitas, Carlos Hobmeier, Amanda Queiroz e Theo Nicoleli on 14/06/25.
//

import SwiftUI

// MARK: - Design Token Protocols

protocol DesignToken {
    associatedtype Value
    var value: Value { get }
}

// MARK: - Color Tokens

enum ColorToken: String, CaseIterable, DesignToken {
    case pokemonBlue = "pokemon_blue"
    case pokemonDarkBlue = "pokemon_dark_blue"
    case pokemonRed = "pokemon_red"
    case pokemonYellow = "pokemon_yellow"
    case pokemonOrange = "pokemon_orange"
    
    case masterBallPurple = "master_ball_purple"
    case masterBallPink = "master_ball_pink"
    case greatBallBlue = "great_ball_blue"
    case ultraBallYellow = "ultra_ball_yellow"
    
    case success = "success"
    case warning = "warning"
    case error = "error"
    case info = "info"
    
    case textPrimary = "text_primary"
    case textSecondary = "text_secondary"
    case textTertiary = "text_tertiary"
    case textOnDark = "text_on_dark"
    case textOnLight = "text_on_light"
    
    case backgroundPrimary = "background_primary"
    case backgroundSecondary = "background_secondary"
    case backgroundTertiary = "background_tertiary"
    case backgroundCard = "background_card"
    
    case surfaceElevated = "surface_elevated"
    case surfaceOverlay = "surface_overlay"
    case surfaceBorder = "surface_border"
    
    case gradientStart = "gradient_start"
    case gradientEnd = "gradient_end"
    
    var value: Color {
        switch self {
        case .pokemonBlue:
            return Color(red: 0.2, green: 0.6, blue: 1.0)
        case .pokemonDarkBlue:
            return Color(red: 0.1, green: 0.4, blue: 0.8)
        case .pokemonRed:
            return Color(red: 0.9, green: 0.2, blue: 0.2)
        case .pokemonYellow:
            return Color(red: 1.0, green: 0.8, blue: 0.0)
        case .pokemonOrange:
            return Color(red: 1.0, green: 0.6, blue: 0.0)
            
        case .masterBallPurple:
            return Color.purple
        case .masterBallPink:
            return Color.pink
        case .greatBallBlue:
            return Color.blue
        case .ultraBallYellow:
            return Color.yellow
            
        case .success:
            return Color.green
        case .warning:
            return Color.orange
        case .error:
            return Color.red
        case .info:
            return Color.blue
            
        case .textPrimary:
            return Color.primary
        case .textSecondary:
            return Color.secondary
        case .textTertiary:
            return Color.primary.opacity(0.6)
        case .textOnDark:
            return Color.white
        case .textOnLight:
            return Color.black
            
        case .backgroundPrimary:
            return Color(.systemBackground)
        case .backgroundSecondary:
            return Color(.secondarySystemBackground)
        case .backgroundTertiary:
            return Color(.tertiarySystemBackground)
        case .backgroundCard:
            return Color.white.opacity(0.95)
            
        case .surfaceElevated:
            return Color.white.opacity(0.15)
        case .surfaceOverlay:
            return Color.white.opacity(0.2)
        case .surfaceBorder:
            return Color.white.opacity(0.3)
            
        case .gradientStart:
            return ColorToken.pokemonBlue.value
        case .gradientEnd:
            return ColorToken.pokemonDarkBlue.value
        }
    }
}

// MARK: - Typography Tokens

enum TypographyToken: String, CaseIterable, DesignToken {
    case displayLarge = "display_large"
    case displayMedium = "display_medium"
    case displaySmall = "display_small"
    
    case headlineLarge = "headline_large"
    case headlineMedium = "headline_medium"
    case headlineSmall = "headline_small"
    
    case titleLarge = "title_large"
    case titleMedium = "title_medium"
    case titleSmall = "title_small"
    
    case bodyLarge = "body_large"
    case bodyMedium = "body_medium"
    case bodySmall = "body_small"
    
    case labelLarge = "label_large"
    case labelMedium = "label_medium"
    case labelSmall = "label_small"
    
    case caption = "caption"
    case overline = "overline"
    
    var value: Font {
        switch self {
        case .displayLarge:
            return .system(size: 36, weight: .bold, design: .rounded)
        case .displayMedium:
            return .system(size: 32, weight: .bold, design: .rounded)
        case .displaySmall:
            return .system(size: 28, weight: .bold, design: .rounded)
            
        case .headlineLarge:
            return .system(size: 24, weight: .bold)
        case .headlineMedium:
            return .system(size: 22, weight: .bold)
        case .headlineSmall:
            return .system(size: 20, weight: .bold)
            
        case .titleLarge:
            return .system(size: 18, weight: .semibold)
        case .titleMedium:
            return .system(size: 16, weight: .semibold)
        case .titleSmall:
            return .system(size: 14, weight: .semibold)
            
        case .bodyLarge:
            return .system(size: 16, weight: .medium)
        case .bodyMedium:
            return .system(size: 14, weight: .medium)
        case .bodySmall:
            return .system(size: 12, weight: .medium)
            
        case .labelLarge:
            return .system(size: 16, weight: .medium)
        case .labelMedium:
            return .system(size: 14, weight: .medium)
        case .labelSmall:
            return .system(size: 12, weight: .medium)
            
        case .caption:
            return .system(size: 11, weight: .medium)
        case .overline:
            return .system(size: 10, weight: .semibold)
        }
    }
}

// MARK: - Spacing Tokens

enum SpacingToken: String, CaseIterable, DesignToken {
    case none = "none"
    case xxs = "xxs"
    case xs = "xs"
    case sm = "sm"
    case md = "md"
    case lg = "lg"
    case xl = "xl"
    case xxl = "xxl"
    case xxxl = "xxxl"
    
    var value: CGFloat {
        switch self {
        case .none: return 0
        case .xxs: return 4
        case .xs: return 8
        case .sm: return 12
        case .md: return 16
        case .lg: return 20
        case .xl: return 24
        case .xxl: return 32
        case .xxxl: return 40
        }
    }
}

// MARK: - Border Radius Tokens

enum BorderRadiusToken: String, CaseIterable, DesignToken {
    case none = "none"
    case xs = "xs"
    case sm = "sm"
    case md = "md"
    case lg = "lg"
    case xl = "xl"
    case full = "full"
    
    var value: CGFloat {
        switch self {
        case .none: return 0
        case .xs: return 4
        case .sm: return 8
        case .md: return 12
        case .lg: return 16
        case .xl: return 20
        case .full: return 25
        }
    }
}

// MARK: - Shadow Tokens

enum ShadowToken: String, CaseIterable, DesignToken {
    case none = "none"
    case sm = "sm"
    case md = "md"
    case lg = "lg"
    case xl = "xl"
    
    var value: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        switch self {
        case .none:
            return (Color.clear, 0, 0, 0)
        case .sm:
            return (Color.black.opacity(0.1), 2, 0, 1)
        case .md:
            return (Color.black.opacity(0.15), 4, 0, 2)
        case .lg:
            return (Color.black.opacity(0.2), 8, 0, 4)
        case .xl:
            return (Color.black.opacity(0.25), 12, 0, 6)
        }
    }
}

// MARK: - Icon Size Tokens

enum IconSizeToken: String, CaseIterable, DesignToken {
    case xs = "xs"
    case sm = "sm"
    case md = "md"
    case lg = "lg"
    case xl = "xl"
    case xxl = "xxl"
    
    var value: CGFloat {
        switch self {
        case .xs: return 12
        case .sm: return 16
        case .md: return 20
        case .lg: return 24
        case .xl: return 32
        case .xxl: return 40
        }
    }
}

// MARK: - Opacity Tokens

enum OpacityToken: String, CaseIterable, DesignToken {
    case transparent = "transparent"
    case light = "light"
    case medium = "medium"
    case strong = "strong"
    case opaque = "opaque"
    
    var value: Double {
        switch self {
        case .transparent: return 0.0
        case .light: return 0.1
        case .medium: return 0.5
        case .strong: return 0.8
        case .opaque: return 1.0
        }
    }
}

// MARK: - Animation Tokens

enum AnimationToken: String, CaseIterable, DesignToken {
    case fast = "fast"
    case medium = "medium"
    case slow = "slow"
    case spring = "spring"
    case bounce = "bounce"
    
    var value: Animation {
        switch self {
        case .fast:
            return .easeInOut(duration: 0.2)
        case .medium:
            return .easeInOut(duration: 0.3)
        case .slow:
            return .easeInOut(duration: 0.5)
        case .spring:
            return .spring(response: 0.6, dampingFraction: 0.8)
        case .bounce:
            return .spring(response: 0.3, dampingFraction: 0.6)
        }
    }
}

// MARK: - Design System Extensions

extension Color {
    static func token(_ token: ColorToken) -> Color {
        return token.value
    }
}

extension Font {
    static func token(_ token: TypographyToken) -> Font {
        return token.value
    }
}

extension View {
    func padding(_ token: SpacingToken) -> some View {
        self.padding(token.value)
    }
    
    func padding(_ edges: Edge.Set = .all, _ token: SpacingToken) -> some View {
        self.padding(edges, token.value)
    }
    
    func cornerRadius(_ token: BorderRadiusToken) -> some View {
        self.cornerRadius(token.value)
    }
    
    func shadow(_ token: ShadowToken) -> some View {
        let shadow = token.value
        return self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
    
    func opacity(_ token: OpacityToken) -> some View {
        self.opacity(token.value)
    }
    
    func iconSize(_ token: IconSizeToken) -> some View {
        self.font(.system(size: token.value))
    }
    
    func animation(_ token: AnimationToken, value: some Equatable) -> some View {
        self.animation(token.value, value: value)
    }
}

// MARK: - Gradient Helpers

extension LinearGradient {
    static var pokemonPrimary: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                ColorToken.pokemonBlue.value,
                ColorToken.pokemonDarkBlue.value
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var pokemonSecondary: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                ColorToken.pokemonYellow.value,
                ColorToken.pokemonOrange.value
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    static var pokemonDanger: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                ColorToken.pokemonRed.value,
                Color(red: 0.6, green: 0.1, blue: 0.4)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Component Style Tokens

enum ComponentStyleToken {
    enum Card {
        static let backgroundColor = ColorToken.backgroundCard.value
        static let cornerRadius = BorderRadiusToken.lg.value
        static let shadow = ShadowToken.md.value
        static let padding = SpacingToken.lg.value
    }
    
    enum Button {
        static let cornerRadius = BorderRadiusToken.full.value
        static let padding = SpacingToken.md.value
        static let shadow = ShadowToken.lg.value
        static let animation = AnimationToken.spring.value
    }
    
    enum TextField {
        static let cornerRadius = BorderRadiusToken.full.value
        static let padding = SpacingToken.md.value
        static let backgroundColor = Color.white.opacity(0.9)
        static let shadow = ShadowToken.sm.value
    }
    
    enum NavigationBar {
        static let backgroundColor = Color.clear
        static let titleFont = TypographyToken.headlineMedium.value
        static let titleColor = ColorToken.textOnDark.value
    }
}

// MARK: - Theme Configuration

struct PokemonTheme {
    static let primaryGradient = LinearGradient.pokemonPrimary
    static let secondaryGradient = LinearGradient.pokemonSecondary
    static let dangerGradient = LinearGradient.pokemonDanger
    
    static let decorativeCircleOpacity = OpacityToken.light.value
    static let cardBackgroundOpacity = 0.95
    static let overlayOpacity = OpacityToken.medium.value
    
    static let sectionSpacing = SpacingToken.xxl.value
    static let itemSpacing = SpacingToken.md.value
    static let insetSpacing = SpacingToken.lg.value
    
    static let defaultAnimation = AnimationToken.medium.value
    static let springAnimation = AnimationToken.spring.value
    static let fastAnimation = AnimationToken.fast.value
}
