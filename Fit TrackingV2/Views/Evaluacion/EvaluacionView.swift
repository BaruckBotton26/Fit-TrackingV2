//
//  EvaluacionView.swift
//  Fit TrackingV2
//
//  Created by Baruck Botton on 1/05/25.
//
/*
import SwiftUI

struct EvaluacionView: View {
    @State private var cameraController: CameraPreviewViewController?
    @State private var navigateToFeedback = false
    @State private var recordedVideoURL: URL?
    @StateObject private var quickPoseVM = QuickPoseViewModel()
    @State private var isRecording = false // 🔥 Nuevo estado para saber si estás grabando

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    CamaraView(
                        onStart: { controller in
                            self.cameraController = controller
                        },
                        onVideoSaved: { videoURL in
                            quickPoseVM.processVideo(from: videoURL)// 🔥 Navegar solo si realmente ya se guardó
                                                    }
                                                )
                            
                    .frame(height: 400)
                    .cornerRadius(12)
                    .clipped()
                    
                    Text(isRecording ? "Grabando ejercicio..." : "Listo para grabar")
                        .font(.title3)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Button(action: {
                        cameraController?.startRecording()
                        isRecording = true // 🔵 Cambia estado
                    }) {
                        Text("Iniciar Grabación")
                            .frame(maxWidth: 180)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(isRecording) // 🔥 Bloquea botón si ya estás grabando
                    
                    Button(action: {
                        cameraController?.stopRecording()
                        isRecording = false // 🔵 Vuelve a estado normal
                        // 🔥 Esperas que onVideoSaved active navigateToFeedback
                    }) {
                        HStack(spacing: 30) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 28))
                            
                            Text("Terminar\nEvaluación")
                                .font(.headline)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: 180)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.blue)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                    }
                    .disabled(!isRecording) // 🔥 Solo puedes terminar si empezaste a grabar
                }
                .padding(.horizontal, 20)
                .padding(.top)
            }
            .onChange(of: quickPoseVM.processedVideoURL) { newValue in
                if newValue != nil {
                    navigateToFeedback = true
                }
            }
            .navigationDestination(isPresented: $navigateToFeedback) {
                if let processedURL = quickPoseVM.processedVideoURL {
                       FeedbackView(videoURL: processedURL)
                   } else {
                       ProgressView("Procesando video...")
                   }
               }
            }
        }
    }
*/
import SwiftUI

struct EvaluacionView: View {
    @State private var navegarAFinal = false
    @StateObject private var summary = PostureEvaluationSummary()

    var body: some View {
        NavigationStack {
            ZStack {
                QuickPoseService(navegarAFinal: $navegarAFinal, summary: summary)

                NavigationLink(destination: FeedbackView(summary: summary),
                               isActive: $navegarAFinal) {
                    EmptyView()
                }
                .hidden()
            }
        }
    }
}

#Preview {
    EvaluacionView()
}
