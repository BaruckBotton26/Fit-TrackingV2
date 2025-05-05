//
//  InicioViewModel.swift
//  Fit TrackingV2
//
//  Created by Baruck Botton on 1/05/25.
//

import Foundation
import AVFoundation

class InicioViewModel: ObservableObject {
    @Published var puedeNavegar = false
    @Published var mostrarAlerta = false

    func solicitarPermisoCamara() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
           
            puedeNavegar = true

        case .notDetermined:
            // 🔥 Aún no se ha pedido permiso, pedirlo ahora
            AVCaptureDevice.requestAccess(for: .video) { acceso in
                DispatchQueue.main.async {
                    if acceso {
                        self.puedeNavegar = true
                    } else {
                        self.mostrarAlerta = true
                    }
                }
            }

        case .denied, .restricted:
            mostrarAlerta = true

        @unknown default:
            mostrarAlerta = true
        }
    }
}
