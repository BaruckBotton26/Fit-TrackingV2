//
//  CamaraView.swift
//  Fit TrackingV2
//
//  Created by Baruck Botton on 1/05/25.
//

import SwiftUI

struct CamaraView: UIViewControllerRepresentable {
    var onStart: (CameraPreviewViewController) -> Void
    var onVideoSaved: (URL) -> Void
    
    func makeUIViewController(context: Context) -> CameraPreviewViewController{
        let controller = CameraPreviewViewController()
        controller.videoGrabado = onVideoSaved
        DispatchQueue.main.async{
            onStart(controller)
        }
        return controller
    }
    func updateUIViewController(_ uiViewController: CameraPreviewViewController, context: Context) {}
    }
