//
//  InicioView.swift
//  Fit TrackingV2
//
//  Created by Baruck Botton on 1/05/25.
//

import SwiftUI
import FirebaseFirestore
struct InicioView: View {
    @StateObject private var viewModel = InicioViewModel()
    var body: some View {
        NavigationStack{
            ScrollView{
                ZStack(alignment: .top) {
                    Color.white.ignoresSafeArea()
                    VStack(spacing:20){
                        Image("hombre-guapo-joven-entrenando-gimnasio-culturismo_23-2149552350")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 365, height: 400)
                                .clipped()
                                .cornerRadius(12)
                                .padding(.top, 0)
                        
                        Button {
                            viewModel.solicitarPermisoCamara()
                                
                        }
                        label: {
                            Label("Comenzar Ejercicio", systemImage: "camera")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .accessibilityIdentifier("comenzarEjercicio")
                        
                        Text("Acerca de")
                            .font(.title2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .bold()
                        ZStack{
                            Rectangle()
                                .fill(Color.white)
                                .cornerRadius(10)
                                .shadow(color: .gray.opacity(0.5), radius: 8, x: 4, y: 8)
                            VStack(alignment: .leading, spacing:0){
                                Text(" Fit Tracking")
                                    .font(.title2)
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                    .padding(.top)
                                    .padding(.bottom)
                                Text("A través de la cámara, nuestra app analiza y mejora tus movimientos deportivos, proporcionando feedback en tiempo real para un entrenamiento más eficaz y seguro.")
                                    .font(.subheadline)
                                    .padding(.bottom)
                                    .padding(.horizontal, 20)
                            }
                        }
                    }
                    .padding()
                    .navigationTitle("Fit Tracking")
                    .navigationDestination(isPresented: $viewModel.puedeNavegar) {
                        ExerciseSelectionView()
                    }
                }
            }
        }
        .onAppear {
            let db = Firestore.firestore()
            db.collection("testLogs").addDocument(data: [
                "mensaje": "¡Firebase conectado!",
                "fecha": Timestamp(date: Date())
            ]) { error in
                if let error = error {
                    print("❌ Error al subir prueba: \(error.localizedDescription)")
                } else {
                    print("✅ Documento de prueba guardado en Firestore")
                }
            }
        }
        
    }
    
    
}
        #Preview {
            InicioView()
        }
