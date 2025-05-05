//
//  AppRootView.swift
//  Fit TrackingV2
//
//  Created by Baruck Botton on 1/05/25.
//

import SwiftUI

struct AppRootView: View {
    @State private var mostrarTabBar = false

        var body: some View {
            ZStack {
                if mostrarTabBar {
                    TabBarContainerView()
                        .transition(.move(edge: .bottom))
                } else {
                    LoadingView()
                        .transition(.opacity)
                }
            }
            .onAppear {
                // Simulamos carga de 2 segundos, reemplázalo con tu lógica real si quieres
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        mostrarTabBar = true
                    }
                }
            }
        }
    }
