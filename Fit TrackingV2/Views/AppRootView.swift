//
//  AppRootView.swift
//  Fit TrackingV2
//
//  Created by Baruck Botton on 1/05/25.
//
import SwiftUI

struct AppRootView: View {
    @State private var mostrarInicio = false

    var body: some View {
        ZStack {
            if mostrarInicio {
                NavigationStack {
                    InicioView()
                }
                .transition(.move(edge: .bottom))
            } else {
                LoadingView()
                    .transition(.opacity)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    mostrarInicio = true
                }
            }
        }
    }
}
