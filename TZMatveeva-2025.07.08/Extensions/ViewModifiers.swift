//
//  ViewModifiers.swift
//  TZMatveeva-2025.07.08
//
//  Created by Валентин on 08.07.2025.
//

import SwiftUI

// MARK: - Bounce Effect для кнопок
struct PressEffect: ViewModifier {
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
            .onTapGesture {
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                }
            }
    }
}

// MARK: - Loading анимация
struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: AppSpacing.standard) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                Text("Сохранение...")
                    .foregroundColor(.white)
                    .font(AppFonts.subtitle)
            }
            .padding(AppSpacing.large)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.card)
                    .fill(AppColors.secondaryBackground.opacity(0.9))
            )
            .scaleEffect(isAnimating ? 1.0 : 0.8)
            .opacity(isAnimating ? 1.0 : 0.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isAnimating)
            .onAppear {
                isAnimating = true
            }
        }
    }
}

// MARK: - Fade In/Out анимация
struct FadeInOut: ViewModifier {
    let isVisible: Bool
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1.0 : 0.0)
            .scaleEffect(isVisible ? 1.0 : 0.9)
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isVisible)
    }
}

extension View {
    func pressEffect() -> some View {
        modifier(PressEffect())
    }
    
    func fadeInOut(isVisible: Bool) -> some View {
        modifier(FadeInOut(isVisible: isVisible))
    }
} 